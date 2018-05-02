#!/bin/bash

NAMESPACE=${NAMESPACE:-maintenability}

cat <<EOL
apiVersion: v1
kind: List
items:
  - apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: weave-scope
      labels:
        name: weave-scope
  - apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRole
    metadata:
      name: weave-scope
      labels:
        name: weave-scope
    rules:
      - apiGroups:
          - '*'
        resources:
          - '*'
        verbs:
          - '*'
      - nonResourceURLs:
          - '*'
        verbs:
          - '*'
  - apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
      name: weave-scope
      labels:
        name: weave-scope
    roleRef:
      kind: ClusterRole
      name: weave-scope
      apiGroup: rbac.authorization.k8s.io
    subjects:
      - kind: ServiceAccount
        name: weave-scope
        namespace: $NAMESPACE
  - apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
      name: weave-scope-app
      labels:
        name: weave-scope-app
        app: weave-scope
        weave-cloud-component: scope
        weave-scope-component: app
    spec:
      replicas: 1
      revisionHistoryLimit: 2
      template:
        metadata:
          labels:
            name: weave-scope-app
            app: weave-scope
            weave-cloud-component: scope
            weave-scope-component: app
        spec:
          containers:
            - name: app
              args:
                - '--mode=app'
              command:
                - /home/weave/scope
              env: []
              image: 'weaveworks/scope:1.9.0'
              imagePullPolicy: IfNotPresent
              ports:
                - containerPort: 4040
                  protocol: TCP
  - apiVersion: v1
    kind: Service
    metadata:
      name: weave-scope-app
      labels:
        name: weave-scope-app
        app: weave-scope
        weave-cloud-component: scope
        weave-scope-component: app
    spec:
      ports:
        - name: app
          port: 80
          protocol: TCP
          targetPort: 4040
      selector:
        name: weave-scope-app
        app: weave-scope
        weave-cloud-component: scope
        weave-scope-component: app
  - apiVersion: extensions/v1beta1
    kind: DaemonSet
    metadata:
      name: weave-scope-agent
      labels:
        name: weave-scope-agent
        app: weave-scope
        weave-cloud-component: scope
        weave-scope-component: agent
    spec:
      minReadySeconds: 5
      template:
        metadata:
          labels:
            name: weave-scope-agent
            app: weave-scope
            weave-cloud-component: scope
            weave-scope-component: agent
        spec:
          containers:
            - name: scope-agent
              args:
                - '--mode=probe'
                - '--probe.docker.bridge=docker0'
                - '--probe.docker=true'
                - '--probe.kubernetes=true'
                - 'weave-scope-app.$NAMESPACE.svc.cluster.local:80'
              command:
                - /home/weave/scope
              env:
                - name: KUBERNETES_HOSTNAME
                  valueFrom:
                    fieldRef:
                      apiVersion: v1
                      fieldPath: spec.nodeName
              image: 'weaveworks/scope:1.9.0'
              imagePullPolicy: IfNotPresent
              securityContext:
                privileged: true
              volumeMounts:
                - name: docker-socket
                  mountPath: /var/run/docker.sock
                - name: scope-plugins
                  mountPath: /var/run/scope/plugins
                - name: sys-kernel-debug
                  mountPath: /sys/kernel/debug
          dnsPolicy: ClusterFirstWithHostNet
          hostNetwork: true
          hostPID: true
          serviceAccountName: weave-scope
          tolerations:
            - effect: NoSchedule
              operator: Exists
          volumes:
            - name: docker-socket
              hostPath:
                path: /var/run/docker.sock
            - name: scope-plugins
              hostPath:
                path: /var/run/scope/plugins
            - name: sys-kernel-debug
              hostPath:
                path: /sys/kernel/debug
      updateStrategy:
        type: RollingUpdate
EOL