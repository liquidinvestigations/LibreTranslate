FROM python:3.8.12-slim-bullseye

ARG with_models=false

WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
  && apt-get -qqq install --no-install-recommends -y libicu-dev pkg-config gcc g++ \
  && apt-get clean \
  && rm -rf /var/lib/apt

RUN pip install --upgrade pip

COPY . .

# check for offline build
RUN if [ "$with_models" = "true" ]; then  \
        # install only the dependencies first
        pip install -e .;  \
        # initialize the language models
        ./install_models.py;  \
    fi

RUN pip install gunicorn

# Install package from source code
RUN pip install . \
  && pip cache purge

ENV OMP_NUM_THREADS=1
ENV OMP_THREAD_LIMIT=1

EXPOSE 5000
ENTRYPOINT [ "/app/runserver" ]
