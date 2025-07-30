# Improving `ramen serve`

The `ramen serve` command should be a first-class OCaml application to provide a better development experience. The current implementation (likely a simple script) should be replaced with a more robust solution.

The `example/dream` application is a good proof-of-concept for this.

## Plan

1.  **Use an OCaml Web Server**:
    -   Implement `ramen serve` in OCaml using a web framework like [Dream](https://aantron.github.io/dream/).
    -   The server's primary job is to serve the static files from the `_site/` directory.

2.  **Implement File Watching**:
    -   Use a file-watching library (e.g., a binding to `fswatch` or `inotify`) to monitor the user's `data/` directory for any changes.

3.  **Automatic Rebuilding**:
    -   When the file watcher detects a change, it should trigger a rebuild of the site by calling the `Ramen.Builder.Site_generator.build()` function.
    -   The initial build should happen once when the server starts up.

4.  **Live Reloading (Advanced)**:
    -   For the best developer experience, implement a live-reloading mechanism.
    -   This typically involves a WebSocket connection between the server and the browser.
    -   After a successful rebuild, the server sends a message to the client, telling the page to refresh automatically.

This will create a self-contained, efficient, and professional development server, making Ramen much easier and more pleasant to use.
