www_hvzatfsu
============

The remake of hvzatfsu.com for the Human vs. Zombies club at FSU.

#### Setup Documentation
1. git clone this repo via command line git (branch + checkout if needed)
2. install nodejs and npm via whatever package manager/installer
3. install nodemon with `npm install nodemon -g`
4. install bower with `npm install bower -g`
5. In the root folder, run `npm install` to install the backend dependencies
6. In the `public/` folder, run `bower install` to install the frontend dependencies
7. In the root directory, run `nodemon` to start the server. If an error occurs, try to fix it and then run `rs` inside of the nodemon session to restart without force closing.
8. Access your test server by going to `http://localhost:PORT/` or `http://LOCAL_IP:PORT/` when you are sharing the network.

**Note:** You will need the `.env` file from Jared containing important API and database keys in order to fully setup the site. You may also get errors without it. Just ask for it.



#### All Routes
##### Public
* `/` `/home` `/index` -- site homepage 
* `/login` -- user login 
* `/signup` -- user signup
* `/info` -- general information (rules, mod info, etc.)

##### User
* `/user/profile` -- user profile  
* `/user/forum` -- forums
* `/user/stats` -- kill leaderboard + general stats


##### Player (access to the game)
* `/game` -- game main
* `/game/missions` --  game mission
* `/game/map` -- dynamic game map
* `/game/kill` -- report a kill

##### Mod
* `/mod/` -- moderator tools home
* `/mod/users` -- user management
* `/mod/game` -- current game management
* `/mod/dev` -- game/mission creation/deletion/management
* `/mod/info` -- website general info management + documentation


#### Things to remember
* If you are adding a dependency with bower or npm, include the `--save` flag in order to automatically add it to the dependency list.
* Place local JS and CSS in the folders mimicing the view folder and with filenames like `folder-page.css` and use the blocks to add them to the page.
* *Obey*