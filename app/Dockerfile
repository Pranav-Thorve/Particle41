# Use a minimal Python 3.12 base image to keep image size small
FROM python:3.12-slim

# Create a non-root user to follow container security best practices
RUN useradd -m appuser

# Set the working directory inside the container
WORKDIR /app

# Copy the application source code into the container
COPY simpletimeservice.py .

# Switch to the non-root user before running the application
USER appuser

# Document the port the application listens on
EXPOSE 8080

# Start the Python application
CMD ["python", "simpletimeservice.py"]
