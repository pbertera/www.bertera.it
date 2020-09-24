Title: Kubernetes semaphore Validating Webhook
Date: 2020-09-24 20:25
Author: Pietro
Tags: Kubernetes, OpenShift

After more than 2 years a new post!

In the path of learning Kubernetes [Dynamic Admission Control](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/) I wrote a small webhook to be used as a semaphore to deny certains operations on k8s objects with a specific label.

[k8s-semaphore](https://github.com/pbertera/k8s-semaphore) is a quick and dirty [web.py](https://webpy.org/) app implementing the webhook, can be deployed on any Kubernetes cluster.

Here is a self-explaining usage of the admission controller:

```
$ cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  annotations:
    bertera.it/k8s-semaphore: red
  name: k8s-semaphore-test
spec:
  containers:
  - name: test
    image: alpine
    # Just spin & wait forever
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
EOF

$ oc get pod test
NAME     READY   STATUS    RESTARTS   AGE
test     1/1     Running   0          29m

$ oc delete test
Error from server: admission webhook "k8s-semaphore.k8s-semaphore.svc" denied the request: Resource test (kind: Pod, version: v1, group: ) is annotated with bertera.it/k8s-semaphore, cannot be removed

$ oc annotate pod test bertera.it/k8s-semaphore-
pod/test annotated

$ oc delete pod test
pod "test" deleted
```

The label name and value can be modified via the environemt variables `SEMAPHORE_ANNOTATION` and `SEMAPHORE_RED`. Depending on the definition of the `ValidatingWebhookConfiguration` the admission controller can be applied to any Kubernetes resource and verbs.

Look at the [manifest.yaml](https://github.com/pbertera/k8s-semaphore/blob/master/manifest.yaml) for an example deployment and `ValidatingWebhookConfiguration`.

Hint: [OpenShift Webhook Certificate Manager](https://github.com/pbertera/ocp-webhook-cert-manager) can help deploying the Webhook certificate on OpenShift.
