# Steps to run the project

## Run it with docker-compose
* If you have docker-compose installed you can just run "docker-compose build" and after that, "docker-compose up" in the root folder of this project

## Run it with npm
* If you want to use npm, first you need to install "npm install" on both backend and frontend folders
* You also need to have a database running. By default the root password is "password". If you have a different root password you need to run one of the following commands on the terminal:
~~~
set DB_PASS=your_password // For windows
export DB_PASS=your_password // For linux
~~~
Also, if you want to change the user, you can do it the same way, with the variable of "DB_USER"
* By default it will create a database named "db" if not exists
* After that, you just need to run "npm run dev" on both folders

In both cases, you will be able to see the frontend on [localhost:5173](http://localhost:5173) and also check the backend on [localhost:3000](http://localhost:3000)

### Feel free to ask me if you have any issue with the code :)
#### And again, thank you for this opportunity <3