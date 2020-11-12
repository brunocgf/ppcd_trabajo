# Traveller salesperson problem \ TSP

mkdir tsp
cd tsp
git init .
touch README.md
mkdir bin
mkdir -p docs conf references
mkdir tsp
mkdir tests
touch LICENSE
touch requirements.txt requirements-dev.txt
touch .gitignore
touch setup.py
touch Dockerfile
touch .python-version
git add README.md requirements.txt requirements-dev.txt setup.py Dockerfile 
cd tsp
touch __init__.py # Modulo de python
git add tsp/
git add .gitignore .python-version LICENSE
pyenv virtualenv 3.7.3 tsp

