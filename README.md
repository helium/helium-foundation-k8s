## Creating Secrets

```
echo -n "...keypair..." | kubectl create secret generic -n helium oracle-keypair --dry-run=client --from-file=keypair.json=/dev/stdin -o yaml > oracle-keypair.yaml

kubeseal <oracle-keypair.yaml -o json >sealed-oracle-keypair.yaml -oyaml

rm -rf oracle-keypair.yaml
```