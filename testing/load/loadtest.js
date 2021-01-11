import http from "k6/http";
import { check, group } from "k6";

// Environmental var input parameters
const API_ENDPOINT = __ENV.TEST_API_ENDPOINT || `http://localhost:8080`;
const STAGE_TIME = __ENV.TEST_STAGE_TIME || "5";

//
// Options, stages and thresholds for load test here
//
export let options = {
  maxRedirects: 4,
  stages: [
    { duration: `${STAGE_TIME}s`, target: 40 },
    { duration: `${STAGE_TIME}s`, target: 80 },
    { duration: `${STAGE_TIME}s`, target: 120 },
    { duration: `${STAGE_TIME}s`, target: 120 },
    { duration: `${STAGE_TIME}s`, target: 80 },
    { duration: `${STAGE_TIME}s`, target: 40 },
    { duration: `${STAGE_TIME}s`, target: 0 },
  ],
  thresholds: {
    http_req_duration: ["avg > 20"],
    http_req_waiting: ["avg > 20"],
  },
};

// Global store of order ids created
var orderIds = {};

export function setup() {
  console.log(`API host tested is: ${API_ENDPOINT}`);
}

export default function () {
  //
  // Loadtest with POST operations
  //
  group("API Creates", function () {
    let url = `${API_ENDPOINT}/api/orders`;
    let payload = JSON.stringify({
      product: "Lemon Curd",
      description: "An order for some delicious lemon curd",
      items: Math.ceil(Math.random() * 100),
    });

    let res = http.post(url, payload, {
      headers: { "Content-Type": "application/json" },
    });

    check(res, {
      "HTTP status was 200": (r) => r.status === 200,
      "New order has an ID": (r) => typeof JSON.parse(r.body).id === "string",
    });

    orderIds[`${__VU}_${__ITER}`] = JSON.parse(res.body).id;
  });

  //
  // Loadtest with GET operations
  //
  group("API Reads", function () {
    let orderId = orderIds[`${__VU}_${__ITER}`];
    let url = `${API_ENDPOINT}/api/orders/${orderId}`;

    let res = http.get(url);

    check(res, {
      "HTTP status was 200": (r) => r.status === 200,
      "Order has product field": (r) =>
        JSON.parse(r.body).product === "Lemon Curd",
    });
  });

  //
  // Loadtest with DELETE operations
  //
  group("API Deletes", function () {
    let orderId = orderIds[`${__VU}_${__ITER}`];
    let url = `${API_ENDPOINT}/api/orders/${orderId}`;

    let res = http.del(url);

    check(res, {
      "Delete operation status was 200": (r) => r.status === 200,
    });
  });
}
