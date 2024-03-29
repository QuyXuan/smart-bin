FROM python:3.10

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt
RUN apt-get update -y && apt-get install -y python3-pip

RUN apt-get install libgl1-mesa-glx -y

CMD ["python", "app.py"]