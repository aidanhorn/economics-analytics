# Observing system resources
# Aidan Horn (aidan@econometrics.co.za)
# Nov 2022

# For Python Anaconda
import datetime
import time
import os
import psutil

print('How frequently should I print the system resources (in minutes, decimals allowed)?')
mins_input = float(input())

print(
    datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '    ' +
    'Available RAM: ' + str(round(psutil.virtual_memory()[4] / (2**(30)))) + ' GiB     ' +
    'CPU usage: ' + str(psutil.cpu_percent(1)) + '%'
)

while True :
    time.sleep(mins_input*30)
    
    print(
		datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '    ' +
        'Available RAM: ' + str(round(psutil.virtual_memory()[4] / (2**(30)))) + ' GiB     ' +
        'CPU usage: ' + str(psutil.cpu_percent(mins_input*30)) + '%'
    )

