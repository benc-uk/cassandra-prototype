import http from "k6/http";
import { check } from "k6";
import { group } from "k6";

//
// Options, stages and thresholds for load test here
//
const STAGE_TIME = __ENV.TEST_STAGE_TIME || "20";
export let options = {
  maxRedirects: 4,
  stages: [
    { duration: `${STAGE_TIME}s`, target: 10 },
    { duration: `${STAGE_TIME}s`, target: 20 },
    { duration: `${STAGE_TIME}s`, target: 60 },
    { duration: `${STAGE_TIME}s`, target: 100 },
    { duration: `${STAGE_TIME}s`, target: 0 },
  ],
  thresholds: {
    "failed requests": ["rate < 0.1"],
    http_req_duration: ["p(90) < 900"],
  },
};

// Environmental input parameters
const API_ENDPOINT = __ENV.TEST_API_ENDPOINT || `http://localhost:8080`;

// Globals
var fruitNames = {};

export function setup() {
  console.log(`Data API host tested is: ${API_ENDPOINT}`);
}

export default function () {
  //
  // Loadtest with POST operations
  //
  group("API Creates", function () {
    let url = `${API_ENDPOINT}/fruits`;
    let name = `Fruit ${Math.floor(Math.random() * 900000)} ${__VU}.${__ITER}`;
    let payload = JSON.stringify({
      description: `Loadtesting data ${__VU}.${__ITER}`,
      name,
    });

    let res = http.post(url, payload, {
      headers: { "Content-Type": "application/json" },
      tags: { name: "CreateFruit" },
    });

    check(res, {
      "POST /fruits: status 200": (r) => r.status === 200,
      "POST /fruits/{name}: new fruit is ok": (r) =>
        typeof JSON.parse(r.body).name === "string",
    });
    fruitNames[`${__VU}_${__ITER}`] = name;
  });

  //
  // Loadtest with GET operations
  //
  group("API Reads", function () {
    let fruitName = fruitNames[`${__VU}_${__ITER}`];
    let url = `${API_ENDPOINT}/fruits/${fruitName}`;

    let res = http.get(url);

    check(res, {
      "GET /fruits: status 200": (r) => r.status === 200,
      "GET /fruits/{name}: fetched fruit is correct": (r) =>
        JSON.parse(r.body).name === fruitName,
    });
  });

  //
  // Loadtest with DELETE operations
  //
  group("API Deletes", function () {
    let fruitName = fruitNames[`${__VU}_${__ITER}`];
    let url = `${API_ENDPOINT}/fruits/${fruitName}`;

    let res = http.del(url);

    check(res, {
      "DELETE /fruits/{name}: status 204": (r) => r.status === 204,
    });
  });
}
