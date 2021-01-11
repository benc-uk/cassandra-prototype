import { check } from "k6";
import http from "k6/http";

export let options = {
  maxRedirects: 4,
  stages: [{ duration: `5s`, target: 1 }],
};

export default function () {
  let res = http.get("http://example.net/dsgssg", {
    tags: {
      mytag: "hello",
    },
  });
  check(
    res,
    {
      "is status 200": (r) => r.status === 200,
      "is status 200": (r) => r.status === 200,
    },
    { my_tag: "I'm a tag" }
  );
}
