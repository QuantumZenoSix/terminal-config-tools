#!/usr/bin/env bash
git clone https://github.com/bobby-valenzuela/ocr-test.git
cd ocr-test/

sudo apt install tesseract-ocr -y          # base + English

uv_start(){
    # 1. Downloads and runs the official uv installation script from Astral
    #    - -L = follow redirects, -s = silent, -S = show errors if any, -f = fail silently on server errors
    #    - This is the recommended one-liner way to install uv (Rust-based, very fast Python tool)
    #    - Installs uv into ~/.cargo/bin or ~/.local/bin (depending on your system)
    command -v uv >/dev/null 2>&1 || curl -LsSf https://astral.sh/uv/install.sh | sh
    [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"


    # 2. Creates a new Python project in the current directory
    #    - Generates a minimal pyproject.toml with modern metadata ([project], [build-system])
    #    - Usually also creates a basic src/ layout or example module + README.md + .gitignore
    #    - This is the current best-practice way to start a Python project (PEP 621 style)
    uv init 2> /dev/null

    # 3. Creates a virtual environment named .venv in the current directory
    #    - Uses the fastest available method (often uv's own Python discovery + venv creation)
    #    - Much faster and more reliable than python -m venv on most systems
    #    - uv will download a Python interpreter if needed (very convenient)
    uv venv

    # 4. Activates the virtual environment you just created
    #    - Modifies your current shell session so python, pip, uv, etc. point to .venv/bin/
    #    - Standard POSIX-style activation (works in bash, zsh, etc.)
    #    - After this line runs, you're "inside" the project’s isolated environment
    source .venv/bin/activate

    # 5. Adds the listed packages as dependencies to pyproject.toml
    #    - Also resolves + installs them into the active .venv immediately
    #    - Automatically creates/updates uv.lock with exact pinned versions (for reproducibility)
    #    - These packages are commonly used together for OCR + image processing tasks:
    #      • pytesseract     → Python interface to Tesseract OCR engine
    #      • numpy           → numerical arrays & math operations
    #      • pipreqs         → generates requirements.txt from your import statements
    #      • opencv-python-headless → OpenCV without GUI/Qt dependencies (ideal for servers, Docker, scripts)
    # uv add pytesseract numpy pipreqs opencv-python-headless

    # 6. Ensures the virtual environment dependencies exactly matches pyproject.toml + uv.lock
    #    - Installs anything missing, removes anything not declared
    #    - Very useful in CI/CD, after git pull, or when collaborating
    #    - Makes the environment 100% reproducible from the lockfile
    uv sync

    printf "\n\n"
    echo " ────────────────────────────────────────────────────────────────────────"
    echo "| Virtual Environment Setup and Synced!                                  |"
    echo "|                                                                        |"
    echo "| # Adding packages                                                      |"
    echo "| \$: uv add numpy                                                       |"
    echo "|                                                                        |"
    echo "|                                                                        |"
    echo "| # Running programs    (try this one now!)                              |"
    echo "| \$: cd ocr-test/                                                       |" # First enter the dir
    echo "| \$: uv run python check_voltages.py                                    |"
    echo " ────────────────────────────────────────────────────────────────────────"
    printf "\n\n"


}

uv_start

echo 'If you get "uv not found" just source your env with "source "$HOME/.local/bin/env" '

