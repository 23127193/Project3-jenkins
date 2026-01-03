# Stage 1: Build stage - use a derived image to install dependencies
# We use a specific Python version base image
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS build

# Set environment variables for optimal compilation
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Set the working directory
WORKDIR /app

# Copy dependency files (pyproject.toml, uv.lock, requirements.txt, etc.)
# This is crucial for Docker's layer caching, ensuring installs are only rerun if these files change
COPY pyproject.toml uv.lock ./

# Install dependencies into a virtual environment in a specific path
RUN uv venv /opt/venv && uv sync --frozen

# Stage 2: Runtime stage - a clean, slim image for production
FROM python:3.12-slim AS runtime

# Set the same working directory
WORKDIR /app

# Copy the pre-installed virtual environment from the build stage
COPY --from=build /opt/venv /opt/venv

# Set environment variable to use the copied venv automatically
ENV PATH="/opt/venv/bin:$PATH"

# Copy your application source code
COPY src/ ./src/

# Command to run your application
CMD ["python", "src/app.py"]
