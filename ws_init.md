# white screen init watchdog test

## first install
```
cd ~ 
rm -rf fb_st7796s
git clone https://github.com/evgs/fb_st7796s.git
cd fb_st7796s
git fetch --all
git checkout ws_init
./install.sh
```

## update
```
cd ~/fb_st7796s
git pull
./install.sh
```
# revert to main branch
```
cd ~ 
rm -r fb_st7796s
git clone https://github.com/evgs/fb_st7796s.git
fb_st7796s/install.sh
```
