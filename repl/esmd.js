const electron = require('electron')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const path = require('path')
const url = require('url')

let mainWindow


function createWindow () {
    mainWindow = new BrowserWindow({
        title: 'Moren',
        autoHideMenuBar: true,
        backgroundColor: "#2e2c29",
        width: 1100,
        height: 700,
        minWidth: 600,
        minHeight: 400,
        icon: path.join(__dirname, '/about/moren/lizard-logo-c.png'),
        webPreferences: {
            webSecurity: false,
            nativeWindowOpen: true
        } });

    // prevent content capture from other app
    mainWindow.setContentProtection(true);

    mainWindow.loadURL(url.format({
        pathname: path.join(__dirname, 'bootmd.html'),
        protocol: 'file:',
        slashes: true
    }))

    mainWindow.webContents.on('new-window',
                              function (event, url, frameName, disposition, options, additionalFeatures) {
                                  event.preventDefault();
                                  if (frameName === 'modal') {
                                      // open window as modal
                                      Object.assign(options, {
                                          modal: true,
                                          parent: mainWindow,
                                          frame: false,
                                          webPreferences: { nativeWindowOpen: true }
                                      });
                                  }
                                  if (frameName === 'frame-native') {
                                      // open window as native chromium
                                      Object.assign(options, {
                                          webPreferences: { nativeWindowOpen: true }
                                      });
                                  }
                                  if (frameName === 'unframe-native') {
                                      // open window as native chromium
                                      Object.assign(options, {
                                          frame: false,
                                          webPreferences: { nativeWindowOpen: true }
                                      });
                                  }
                                  event.newGuest = new BrowserWindow(options);
                              });
}



app.on('ready', createWindow)


app.on('window-all-closed', function () {
    if (process.platform !== 'darwin') {
        app.quit()
    }
})

app.on('activate', function () {
    if (mainWindow === null) {
        createWindow()
    }
})



// EOF
