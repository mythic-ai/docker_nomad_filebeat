import requests
import os
headers = {"X-Nomad-Token": os.environ['NOMAD_TOKEN']}
r = requests.get('https://nomad.mythic-ai.com/v1/allocation/{}'.format(os.environ['NOMAD_ALLOC_ID']), headers=headers)
allocation_tasks =  r.json()['AllocatedResources']['Tasks']
for task in allocation_tasks.keys():
    if task != 'batch_job_logger':
        device_ids = []
        for device in allocation_tasks[task]['Devices']:
            device_ids = device_ids + device['DeviceIDs']
        print(",".join(device_ids))
