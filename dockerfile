FROM python:3.8-slim
# Using official Python runtime as a parent image

WORKDIR /app

COPY . /app
# Copying the current directory contents into the container at /app

RUN pip install --no-cache-dir -r requirements.txt
# Install any needed packages specified in requirements.txt

EXPOSE 5000

ENV FLASK_APP=app.py
ENV FLASK_ENV=development
# Define environment variables

CMD ["flask", "run", "--host=0.0.0.0"]
# Run app.py when the container launches
