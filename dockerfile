FROM python:slim-buster

WORKDIR /app

COPY ./app/app.py ./requirements.txt  ./
RUN pip3 install -r requirements.txt

EXPOSE 5000

CMD ["python3", "app.py"]