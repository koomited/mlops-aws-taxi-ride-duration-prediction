# pylint: disable=duplicate-code
import json

import requests
from deepdiff import DeepDiff

with open('event.json', 'rt', encoding='utf-8') as f_in:
    event = json.load(f_in)


# url = "http://localhost:8080/2015-03-31/functions/function/invocations"
host = "https://hqzcpsf1r2.execute-api.us-east-1.amazonaws.com/test/predict"
actual_response = requests.post(host, json=event, timeout=20).json()
print("Actual response:")

print(json.dumps(actual_response, indent=2))

expected_response = {
    'predictions': [
        {
            'model': 'ride-duration-prediction-model',
            'version': "Test123",
            'prediction': {
                'ride_duration': 18.120189001540375,
                'ride_id': 256,
            },
        }
    ]
}

# diff = DeepDiff(actual_response, expected_response, significant_digits=3)
# print('diff=', diff)

# assert 'type_changes' not in diff
# assert 'values_changed' not in diff


# assert  actual_response == expected_response
