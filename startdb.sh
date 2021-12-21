export loc1="eastus"
export loc2="westus"
export loc3="northeurope"

cockroach cert create-node \
localhost 127.0.0.1cockroachdb-public \
cockroachdb-public.default \
cockroachdb-public.$loc3 \
cockroachdb-public.$loc3.svc.cluster.local \
*.cockroachdb \
*.private.cockroach.internal \
*.cockroachdb.$loc3 \
*.cockroachdb.$loc3.svc.cluster.local \
--certs-dir=/home/ubuntu/cockroach/certs \
--ca-key=/home/ubuntu/cockroach/my-safe-directory/ca.key

cockroach start \
        --certs-dir=/home/ubuntu/cockroach/certs \
        --store=/home/ubuntu/cockroach/$(hostname) \
        --listen-addr=$(hostname -f):26257 \
        --advertise-addr=$(hostname -f) \
        --http-addr=$(hostname -f):8080 \
        --locality=region=northeneurope \
        --join=crdb-$loc1-node1.private.cockroach.internal:26257,crdb-$loc1-node2.private.cockroach.internal:26257,crdb-$loc1-node3.private.cockroach.internal:26257,crdb-$loc2-node1.private.cockroach.internal:26257,crdb-$loc2-node2.private.cockroach.internal:26257,crdb-$loc2-node3.private.cockroach.internal:26257,crdb-$loc3-node1.private.cockroach.internal:26257,crdb-$loc3-node2.private.cockroach.internal:26257,crdb-$loc3-node3.private.cockroach.internal:26257 \
        --background &