#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <libgen.h>
#include <ftw.h>
#include <signal.h>

#define TMP_TEMPLATE "/tmp/x3-XXXXXX"
#define BUF_SIZE 8192

static char g_tmpdir[sizeof(TMP_TEMPLATE)] = {0};
static pid_t g_child_pid = -1;
static int g_cleaned = 0;
static int g_isolation_active = 0;

void copy_file(const char *src, const char *dst)
{
    FILE *in = fopen(src, "rb");
    if (!in) exit(1);

    FILE *out = fopen(dst, "wb");
    if (!out) {
        fclose(in);
        exit(1);
    }

    char buf[BUF_SIZE];
    size_t n;
    while ((n = fread(buf, 1, sizeof(buf), in)) > 0)
        fwrite(buf, 1, n, out);

    fclose(in);
    fclose(out);
}

static int unlink_cb(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
    return remove(fpath);
}

void rm_rf(const char *path)
{
    nftw(path, unlink_cb, 64, FTW_DEPTH | FTW_PHYS);
}

void cleanup(void)
{
    if (!g_isolation_active || g_cleaned)
        return;

    g_cleaned = 1;

    if (g_child_pid > 0) {
        kill(g_child_pid, SIGTERM);
        waitpid(g_child_pid, NULL, WNOHANG);
    }

    rm_rf(g_tmpdir);
    printf("[x3] Cleanup complete: %s\n", g_tmpdir);
}

void handle_signal(int sig)
{
    if (g_isolation_active) {
        printf("\n[x3] Caught signal %d, cleaning up\n", sig);
        cleanup();
    }
    _exit(128 + sig);
}

void open_file_manager(const char *path)
{
    const char *fm = getenv("XDG_FILE_MANAGER");
    if (!fm)
        fm = "thunar";

    printf("[x3] Launching file manager: %s\n", fm);
    printf("[x3] Path: %s\n", path);

    execlp(fm, fm, path, NULL);
    execlp("nautilus", "nautilus", path, NULL);
    execlp("xdg-open", "xdg-open", path, NULL);
    exit(1);
}

int file_exists(char **files, int count, const char *path)
{
    for (int i = 0; i < count; i++)
        if (strcmp(files[i], path) == 0)
            return 1;
    return 0;
}

char *unique_dest_path(const char *dir, const char *base)
{
    char *name = strdup(base);
    char *ext = strrchr(name, '.');
    int n = 1;
    char *path;

    asprintf(&path, "%s/%s", dir, name);

    while (access(path, F_OK) == 0) {
        free(path);
        n++;
        if (ext) {
            *ext = 0;
            asprintf(&path, "%s/%s_%d.%s", dir, name, n, ext + 1);
            *ext = '.';
        } else {
            asprintf(&path, "%s/%s_%d", dir, name, n);
        }
    }

    free(name);
    return path;
}

int main(int argc, char *argv[])
{
    setvbuf(stdout, NULL, _IONBF, 0);

    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);

    if (argc == 1) {
        char *cwd = getcwd(NULL, 0);
        if (!cwd) return 1;

        printf("[x3] Opening current directory\n");

        pid_t pid = fork();
        if (pid == 0)
            open_file_manager(cwd);

        waitpid(pid, NULL, 0);
        free(cwd);
        return 0;
    }

    if (argc == 2) {
        char *path = realpath(argv[1], NULL);
        if (!path) return 1;

        struct stat st;
        if (stat(path, &st) != 0) {
            free(path);
            return 1;
        }

        if (S_ISDIR(st.st_mode)) {
            printf("[x3] Opening directory\n");

            pid_t pid = fork();
            if (pid == 0)
                open_file_manager(path);

            waitpid(pid, NULL, 0);
            free(path);
            return 0;
        }
    }

    char **files = calloc(argc - 1, sizeof(char *));
    int file_count = 0;

    for (int i = 1; i < argc; i++) {
        char *rp = realpath(argv[i], NULL);
        if (!rp) continue;

        struct stat st;
        if (stat(rp, &st) != 0 || !S_ISREG(st.st_mode)) {
            free(rp);
            continue;
        }

        if (!file_exists(files, file_count, rp))
            files[file_count++] = rp;
        else
            free(rp);
    }

    if (file_count == 0)
        return 1;

    strcpy(g_tmpdir, TMP_TEMPLATE);
    if (!mkdtemp(g_tmpdir))
        return 1;

    g_isolation_active = 1;

    printf("[x3] Opening files in isolation\n");
    printf("[x3] Isolated directory : %s\n", g_tmpdir);

    for (int i = 0; i < file_count; i++) {
        char *base = basename(files[i]);
        char *dst = unique_dest_path(g_tmpdir, base);

        printf("[x3] Source      : %s\n", files[i]);
        printf("[x3] Destination : %s\n", dst);

        copy_file(files[i], dst);
        chmod(dst, 0444);
        free(dst);
    }

    g_child_pid = fork();
    if (g_child_pid == 0)
        open_file_manager(g_tmpdir);

    waitpid(g_child_pid, NULL, 0);
    cleanup();

    for (int i = 0; i < file_count; i++)
        free(files[i]);
    free(files);

    return 0;
}
