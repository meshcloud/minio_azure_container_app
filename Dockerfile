FROM quay.io/minio/minio:RELEASE.2025-04-22T22-12-26Z

EXPOSE 9000
EXPOSE 9001

VOLUME [/data]

CMD ["minio", "server", "/data", "--console-address", ":9001"]





kubectl run minio --image=quay.io/minio/minio:RELEASE.2025-04-22T22-12-26Z --port=9000 --port=9001 -o yaml --dry-run=client > minio_pod.yaml