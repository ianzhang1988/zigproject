const std = @import("std");

const c = @cImport({
    @cInclude("librdkafka/rdkafka.h");
});

pub fn main() !void {

    // var allocator = std.heap.page_allocator;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    var allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip();

    const server = args.next().?;

    // Kafka Producer
    const conf = c.rd_kafka_conf_new();
    defer c.rd_kafka_conf_destroy(conf);

    if (conf != null) {
        std.debug.print("conf is ok\n", .{});
    } else {
        std.debug.print("Failed to get conf\n", .{});
    }

    const errstr_len = 512;
    var errstr: [errstr_len]u8 = undefined;

    const result = c.rd_kafka_conf_set(conf, "bootstrap.servers", &server[0], &errstr[0], errstr_len);
    if (result != 0) {
        std.debug.print("Failed to set conf: {s}\n", .{errstr});
        return;
    }

    const producer = c.rd_kafka_new(c.RD_KAFKA_PRODUCER, conf, &errstr[0], errstr_len);
    if (producer == null) {
        std.debug.print("Failed to create producer: {s}\n", .{errstr});
        return;
    }
    defer c.rd_kafka_destroy(producer);

    const topic_name = "kafka-go-test_0";
    const topic_conf = c.rd_kafka_topic_conf_new();
    defer c.rd_kafka_topic_conf_destroy(topic_conf);

    const topic = c.rd_kafka_topic_new(producer, topic_name, topic_conf);
    if (topic == null) {
        std.debug.print("Failed to create topic\n", .{});
        return;
    }
    defer c.rd_kafka_topic_destroy(topic);

    const payload = "Hello, Kafka!";
    // const len = std.mem.len(@as([*]const u8, @ptrCast(payload)));
    const len = payload.len;

    const produce_result = c.rd_kafka_produce(topic, c.RD_KAFKA_PARTITION_UA, c.RD_KAFKA_MSG_F_COPY, @as(*anyopaque, @ptrCast(@constCast(payload))), len, null, 0, null);

    if (produce_result != 0) {
        std.debug.print("Failed to produce message: {s}\n", .{c.rd_kafka_err2str(c.rd_kafka_last_error())});
        return;
    }

    std.debug.print("Message produced: {s}\n", .{payload});

    // Kafka Consumer
    const conf_consumer = c.rd_kafka_conf_new();
    defer c.rd_kafka_conf_destroy(conf_consumer);

    _ = c.rd_kafka_conf_set(conf_consumer, "group.id", "test_group", &errstr[0], errstr_len);
    _ = c.rd_kafka_conf_set(conf_consumer, "bootstrap.servers", &server[0], &errstr[0], errstr_len);
    _ = c.rd_kafka_conf_set(conf_consumer, "auto.offset.reset", "earliest", &errstr[0], errstr_len);

    const consumer = c.rd_kafka_new(c.RD_KAFKA_CONSUMER, conf_consumer, &errstr[0], errstr_len);
    if (consumer == null) {
        std.debug.print("Failed to create consumer: {s}\n", .{errstr});
        return;
    }
    defer c.rd_kafka_destroy(consumer);

    _ = c.rd_kafka_subscribe(consumer, createTopicList(&allocator, topic_name));

    while (true) {
        const msgs = c.rd_kafka_consumer_poll(consumer, 1000);
        if (msgs != null) {
            const msg = msgs[0];

            if (msg.err == c.RD_KAFKA_RESP_ERR_NO_ERROR) {
                // std.debug.print("typeof msg.payload {?}\n", .{@TypeOf(msg.payload)});
                std.debug.print("Received message: {s}\n", .{std.mem.span(@as([*c]const u8, @ptrCast(msg.payload.?)))});
                c.rd_kafka_message_destroy(msgs);
            }
        }
    }
}

// fn createTopicList(allocator: *std.mem.Allocator, topic_name: []const u8) *c.rd_kafka_topic_partition_list_t {
fn createTopicList(_: *std.mem.Allocator, topic_name: []const u8) *c.rd_kafka_topic_partition_list_t {
    const list = c.rd_kafka_topic_partition_list_new(1);
    _ = c.rd_kafka_topic_partition_list_add(list, @ptrCast(topic_name), c.RD_KAFKA_PARTITION_UA);
    return list;
}
