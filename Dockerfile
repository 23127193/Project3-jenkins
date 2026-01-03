# Stage 1: Build
FROM python:3.9-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.9-slim
WORKDIR /app
# Chỉ copy các thư viện đã cài đặt từ stage builder
COPY --from=builder /root/.local /root/.local
COPY /src ./src/
ENV PATH=/root/.local/bin:$PATH
EXPOSE 5000
CMD ["python", "./src/app.py"]
