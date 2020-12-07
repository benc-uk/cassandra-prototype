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
    { duration: `${STAGE_TIME}s`, target: 50 },
    { duration: `${STAGE_TIME}s`, target: 80 },
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
var eventIds = {};

export function setup() {
  console.log(`Data API host tested is: ${API_ENDPOINT}`);
}

export default function () {
  //
  // Loadtest with POST operations
  //
  group("API Creates", function () {
    let url = `${API_ENDPOINT}/fruits`;
    let payload = JSON.stringify({
      description: `Loadtesting data ${__VU}.${__ITER}`,
      name: `Fruit ${Math.floor(Math.random() * 8000)}`,
    });

    let res = http.post(url, payload, {
      headers: { "Content-Type": "application/json" },
    });

    check(res, {
      "POST /fruits: status 204": (r) => r.status === 204,
      // "POST /api/events: resp event is valid": (r) =>
      //   JSON.parse(r.body).type === "event",
      // "POST /api/events: resp event has ID": (r) =>
      //   typeof JSON.parse(r.body)._id === "string",
    });
    //eventIds[`${__VU}_${__ITER}`] = JSON.parse(res.body)._id;
  });

  //
  // Loadtest with GET operations
  //
  group("API Reads", function () {
    //let eventId = eventIds[`${__VU}_${__ITER}`];
    let url = `${API_ENDPOINT}/fruits`;

    let res = http.get(url, { tags: { name: "GetFruits" } });

    check(res, {
      "GET /fruits: status 200": (r) => r.status === 200,
      //"GET /api/events/{id}: fetched event is ok": (r) => JSON.parse(r.body)._id === eventId,
    });
  });
}
