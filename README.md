# HTTP 415 Error Demo

This project demonstrates how to handle HTTP 415 Unsupported Media Type errors in a simple Python web server.

## About

The `web_server.py` script starts a basic HTTP server that listens on port 8888. It's configured to accept `POST` requests only with a `Content-Type` of `application/text`.

- If a `POST` request is received with a supported content type, the server echoes the request body back in the response.
- If the content type is not supported, the server responds with a `415 Unsupported Media Type` error and includes an `Accept-Post` header to indicate which content types are allowed.
- The server also responds to `OPTIONS` requests, returning the allowed methods (`OPTIONS`, `POST`) and the accepted content types in the `Accept-Post` header.

## Usage

1.  **Start the server:**
    ```bash
    python web_server.py
    ```

2.  **Run the tests:**
    The `test.sh` script sends a few sample requests to the server to demonstrate the expected behavior. It supports multiple output formats:

    -   **`./test.sh`**: Default, human-readable table.
    -   **`./test.sh --raw`**: Raw, pipe-separated output for scripting.
    -   **`./test.sh --json`**: JSON output for machine consumption.

    ### `gum table` Integration

    There is a known issue with `gum table` in the current environment where it fails to parse valid JSON. As a result, the following command does not work:

    ```bash
    # This command currently fails due to an issue with gum table
    ./test.sh --json | gum table
    ```

## Reproducible Development Environment

This project uses `devenv` to create a reproducible development environment. The `devenv.nix` and `devenv.yaml` files define the required packages and configuration, including `python`, `gum`, and `jq`.

To activate the environment, run:
```bash
devenv shell
```

This will install the necessary dependencies and make them available in your shell.

