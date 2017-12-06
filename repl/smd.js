const electron = require('electron')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const path = require('path')
const url = require('url')

let mainWindow

function createWindow () {
    mainWindow = new BrowserWindow({width: 1100, height: 700, icon: 'Lizard.png'})
    mainWindow.loadURL(url.format({
        pathname: path.join(__dirname, 'bootmd.html'),
        protocol: 'file:',
        slashes: true
    }))
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
