# plain-elasticsearch
Plain Docker image w/ elasticsearch which can be deployed as Docker Services.

The image can be used as single container (Master/Data) deployment or in a distributed setup.


## Single Image Service

If you resources are limited (laptop), you should consider starting only one instance.

```
$ docker stack deploy -c docker-compose.yml es
Creating network es_default
Creating service es_master
$ sleep ${DELAY} ; docker ps -f label=com.docker.stack.namespace=es --format '{{.Names}}\t{{.Image}}\t\t{{.Status}}'
es_master.1.8ch3vysxxug64rivqptjl4xpt	qnib/plain-elasticsearch:latest		Up 58 seconds (healthy)
$ curl -s http://localhost:9200/_cluster/health |jq .
{
  "cluster_name": "default",
  "status": "green",
  "timed_out": false,
  "number_of_nodes": 1,
  "number_of_data_nodes": 1,
  "active_primary_shards": 0,
  "active_shards": 0,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 100
}
$
```

## Distributed Docker Services

In a distributed setup (when `ES_UNICAST_HOSTS` is set), the data nodes are wait to start until the master cluster status is green.

```
$ docker stack deploy --compose-file docker-compose.yml.distributed es
Creating network es_default
Creating service es_data
Creating service plain-elasticsearch_master
$ sleep ${DELAY} ; docker ps -f label=com.docker.stack.namespace=es
CONTAINER ID        IMAGE                             COMMAND                  CREATED             STATUS                            PORTS               NAMES
f6a3e9faa746        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   2 minutes ago       Up 2 minutes (healthy)                                plain-elasticsearch_master.1.tiipl0ayio9ie8k9xj87usqqm
e034716bb411        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   2 minutes ago       Up 2 minutes (health: starting)                       plain-elasticsearch_data.1.0o7luees7o2ttlmnvlw4og8jr
fdfe3db38fd1        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   5 minutes ago       Up 5 minutes (health: starting)                       plain-elasticsearch_data.2.et0tszukn87a6xotfhxmlw3fl
bc3fcbd11931        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   5 minutes ago       Up 5 minutes (health: starting)                       plain-elasticsearch_data.3.rd311hj3h7v4ho5bih8f0yovw
$
```

After the master turns green...

```
> execute entrypoint '/opt/qnib/entry/99-wait-for-master.sh'
  >> ES_UNICAST_HOSTS is set 'plain-elasticsearch_master. Waiting until master is up...
2017/04/07 08:34:50 Check URL: http://plain-elasticsearch_master:9200/_cat/health?h=status
2017/04/07 08:34:50 200 | Status;green
2017/04/07 08:34:50 Cluster is green...
> execute CMD as user 'elasticsearch'
```

...the data nodes become healthy as well:

```
$ docker ps -f label=com.docker.stack.namespace=es
CONTAINER ID        IMAGE                             COMMAND                  CREATED             STATUS                   PORTS               NAMES
21e542d338ec        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   2 minutes ago       Up 2 minutes (healthy)                       es_data.1.im21bxb1r5g1farb33p3jf3e8
1c04e55b0d41        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   2 minutes ago       Up 2 minutes (healthy)                       es_data.3.1tm4z1xapf1r4z0ay8lzpikie
61b487f5770e        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   2 minutes ago       Up 2 minutes (healthy)                       es_data.2.s7s8amxaf1xvi39du1o3umchr
0a7e433f3d00        qnib/plain-elasticsearch:latest   "/usr/local/bin/en..."   2 minutes ago       Up 2 minutes (healthy)                       es_master.1.rjaelqjfk0e24ism2zneo5qb9
$ curl -s http://localhost:9200 |jq .
{
  "name": "0a7e433f3d00",
  "cluster_name": "default",
  "cluster_uuid": "8TbFIAunS2ehLBZ1osdVmA",
  "version": {
    "number": "5.3.0",
    "build_hash": "3adb13b",
    "build_date": "2017-03-23T03:31:50.652Z",
    "build_snapshot": false,
    "lucene_version": "6.4.1"
  },
  "tagline": "You Know, for Search"
}
$ curl -s http://localhost:9200/_cluster/health |jq .
{
  "cluster_name": "default",
  "status": "green",
  "timed_out": false,
  "number_of_nodes": 4,
  "number_of_data_nodes": 3,
  "active_primary_shards": 0,
  "active_shards": 0,
  "relocating_shards": 0,
  "initializing_shards": 0,
  "unassigned_shards": 0,
  "delayed_unassigned_shards": 0,
  "number_of_pending_tasks": 0,
  "number_of_in_flight_fetch": 0,
  "task_max_waiting_in_queue_millis": 0,
  "active_shards_percent_as_number": 100
}
$
```

On a laptop this might take some minutes to starting up, you might want to move from three to one data nodes...

![](/resources/pics/3cnt_memory.png)

## Rolling update

When updating the image...

```
$ docker build -t qnib/$(basename $(pwd)):local .
$ docker service update --image qnib/$(basename $(pwd)):local es_data
```

...the rolling update will take one task at a time, wait until the service is `healthy` and have a delay of `30s` (see `docker-compose.yml`) in between tasks.

```
$ docker ps -f label=com.docker.stack.namespace=es
CONTAINER ID        IMAGE                            COMMAND                  CREATED              STATUS                           PORTS               NAMES
17d678dcbfdd        qnib/plain-elasticsearch:local   "/usr/local/bin/en..."   6 seconds ago        Up 1 second (health: starting)                       es_data.1.4uu9oq5pieof5h7pvnak08z8p
18b52bc1a045        qnib/plain-elasticsearch:local   "/usr/local/bin/en..."   About a minute ago   Up About a minute (healthy)                          es_data.3.uz2rplm3eiodl97e431sdteef
61b487f5770e        qnib/plain-elasticsearch:latest  "/usr/local/bin/en..."   8 minutes ago        Up 8 minutes (healthy)                               es_data.2.s7s8amxaf1xvi39du1o3umchr
0a7e433f3d00        qnib/plain-elasticsearch:latest  "/usr/local/bin/en..."   8 minutes ago        Up 8 minutes (healthy)                               es_master.1.rjaelqjfk0e24ism2zneo5qb9
```

# Kibana
Missing in the stack is a dependency with kibana, which will be prototypes in `qnib/plain-kibana` and inserted later.
