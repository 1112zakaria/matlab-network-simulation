# matlab-network-simulation

Putting these scripts here for easy access in the meantime

To run Matlab script in headless mode on version R2019 or newer, run:
```
matlab -batch "<script name w/ no .m>"
```
Example:
```
matlab -batch "prototype"
```

## Setup
It is recommended to setup a Python virtual environment. To do this, run:
```
python3 -m venv .venv
```

Then, install the necessary dependencies via:
```
pip install -r requirements.txt
```
You will have to also install the Matlab compiled Python package(s). To do so, run the following inside each package directory:
```
python setup.py install
```

## Deploy in Docker
You can deploy this application in a Docker container environment via the following scripts. Note that the Docker image will eat up about ~10-11 GB of disk space ;-;

To build:
```
sh ./build.sh
```

To run:
```
sh ./run.sh
```