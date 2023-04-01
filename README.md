# Idisclose

mix phx.gen.release --docker
MIX_ENV=prod mix release
docker build -t marioanticoli/idisclose .
docker run -p4000:4000 --network='host' -e DATABASE_URL='ecto://postgres:postgres@127.0.0.1/idisclose_dev' -e SECRET_KEY_BASE='ot5S9pvpv/FHERTx6NEJLq7E6Mvt/WDk8wDjnLEgtvSTz317sKa2yUMCRKxuwzOw' marioanticoli/idisclose

