# Todo React Frontend

## Parameters
- `-e PORT=80`: Listening port of the Nginx container. Default: `80`
- `-e RUNTIME_API_URL=`: Backend API URL
- `-e RUNTIME_ENABLE_BACKEND_PROXY=false`: Set to `true` and use with `-e RUNTIME_PROXY_BACKEND` to set the backend, which Nginx will proxy based on `-e RUNTIME_API_URL`. Default: `false`
- `-e RUNTIME_PROXY_BACKEND=`: Backend where Nginx will proxy (e.g. `http://todo-backend:8000`)
- `-e RUNTIME_JS_VAR_*`: Any variables that start with ` RUNTIME_JS_VAR_` will be accessible within React by `window._env_.RUNTIME_JS_VAR_*`. This is NOT for sensitive information

## Run directly
```
cd ./app
yarn install
export RUNTIME_API_URL=
yarn build
```

## Docker run (without proxying Backend API)
```
docker run \
-d \
--name todo-frontend \
-e PORT=80 \
-e RUNTIME_API_URL= https://todo.domain.tld/api/ \
-e RUNTIME_ENABLE_BACKEND_PROXY=false \
-p 3000:80/tcp \
longhtran91/todo-frontend
```

## Docker compose (without proxying Backend API)
```
name: Todo App
services:
  todo-frontend:
    container_name: todo-frontend
    environment:
      - PORT=80
      - RUNTIME_API_URL= https://todo.domain.tld/api/
      - RUNTIME_ENABLE_BACKEND_PROXY=false
    ports:
      - 3000:80/tcp
    image: longhtran91/todo-frontend
```

## Kubernetes (proxying Backend API)
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-frontend-deployment
  namespace: todo
  labels:
    app: todo-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: todo-frontend
  template:
    metadata:
      labels:
        app: todo-frontend
    spec:
      containers:
        - name: todo-frontend
          image: longhtran91/todo-frontend
          ports:
            - containerPort: 80
          env:
            - name: PORT
              value: 80
            - name: RUNTIME_API_URL
              value: /api/
            - name: RUNTIME_ENABLE_BACKEND_PROXY
              value: true
            - name: RUNTIME_PROXY_BACKEND
              value: http://todo-backend-svc:8000 # this matches the todo-backend-svc service and port                               
---
apiVersion: v1
kind: Service
metadata:
  name: todo-backend-svc
  namespace: todo
spec:
  ports:
    - name: http
      port: 8000
      targetPort: 8000
      protocol: TCP
  type: ClusterIP
  selector:
    app: todo-backend
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: todo-backend-deployment
  namespace: todo
  labels:
    app: todo-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: todo-backend
  template:
    metadata:
      labels:
        app: todo-backend
    spec:
      containers:
        - name: todo-backend
          image: longhtran91/todo-backend
          ports:
            - containerPort: 8000
          env:
            - name: PORT
              value: 8000
            - name: DB_STRING
              valueFrom:
                secretKeyRef:
                  name: todo-backend-secret
                  key: DB_STRING
---
apiVersion: v1
kind: Secret
metadata:
  name: todo-backend-secret
  namespace: todo
type: Opaque
data:
  DB_STRING: bXlzcWwrcHltcXlvdTp1c2VyOnBhc3NAcmVmcmVzaEBtYXJpYWRiX2hvc3RvbmdpbmVkL2Ri #base64-encoded
```