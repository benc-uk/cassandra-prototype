import time
import json
from locust import HttpUser, task, SequentialTaskSet

class OrderAPIUser(HttpUser):
  @task
  class SequenceOfTasks(SequentialTaskSet):
    id = ""

    @task
    def postOrder(self):
      payload = {
        "product": "Lemon Curd",
        "description": "An order for some delicious lemon curd",
        "items": 158
      }

      with self.client.post("/api/orders", data=json.dumps(payload), catch_response=True) as response:
        if "id" not in response.text:
          response.failure("New order wasn't valid")
          return
        newOrder = json.loads(response.text)
        self.id = newOrder["id"]

    @task
    def getOrder(self):
      self.client.get(f"/api/orders/{self.id}", name="/api/order/id")

    @task
    def deleteOrder(self):
      self.client.delete(f"/api/orders/{self.id}", name="/api/order/id")