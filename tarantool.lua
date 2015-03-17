#!/usr/bin/env tarantool

work_dir = "/data"

slab_alloc_arena = 1.0

primary_port = 3301

box.cfg{
    work_dir=work_dir,
    listen=primary_port,
    slab_alloc_arena=slab_alloc_arena
}

demo = box.space.demo
if not demo then
    demo = box.schema.create_space('demo')
    demo:create_index('primary', {type = 'hash', parts = {1, 'NUM'}})
end
