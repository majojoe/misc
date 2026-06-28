FROM python:3.9-alpine
RUN pip install flask
COPY app.py /app.py
ENV PORT 5000
CMD ["python", "/app.py"]
HEALTHCHECK --interval=10s --timeout=5s --retries=2 \
  CMD curl --fail http://localhost:$PORT/healthcheck || exit 1
