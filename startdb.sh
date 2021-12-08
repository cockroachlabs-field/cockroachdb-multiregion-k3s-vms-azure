sudo dhclient -v

cockroach start \
        --certs-dir=/home/ubuntu/cockroach/certs \
        --store=/home/ubuntu/cockroach/$(hostname) \
        --listen-addr=$(hostname -f):26257 \
        --advertise-addr=$(hostname -f) \
        --http-addr=$(hostname -f):8080 \
        --locality=region=northeneurope \
        --join=crdb-$loc1-node1.private.cockroach.internal:26257,crdb-$loc1-node2.private.cockroach.internal:26257,crdb-$loc1-node3.private.cockroach.internal:26257,crdb-$loc2-node1.private.cockroach.internal:26257,crdb-$loc2-node2.private.cockroach.internal:26257,crdb-$loc2-node3.private.cockroach.internal:26257,crdb-$loc3-node1.private.cockroach.internal:26257,crdb-$loc3-node2.private.cockroach.internal:26257,crdb-$loc3-node3.private.cockroach.internal:26257 \
        --background &