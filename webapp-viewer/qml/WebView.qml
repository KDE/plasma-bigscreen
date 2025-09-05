// SPDX-FileCopyrightText: 2014-2015 Sebastian Kügler <sebas@kde.org>
//
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtWebEngine

import org.kde.kirigami as Kirigami

import org.kde.bigscreen.webapp as WebApp

WebEngineView {
    id: webEngineView

    // int, but we want nullability
    property var errorCode: null
    property var errorDomain: null
    property string errorString: ""

    property bool privateMode: false

    property var userAgent: WebApp.UserAgent

    // loadingActive property is set to true when loading is started
    // and turned to false only after successful or failed loading. It
    // is possible to set it to false by calling stopLoading method.
    //
    // The property was introduced as it triggers visibility of the webEngineView
    // in the other parts of the code. When using loading that is linked
    // to visibility, stop/start loading was observed in some conditions. It looked as if
    // there is an internal optimization of webengine in the case of parallel
    // loading of several pages that could use visibility as one of the decision
    // making parameters.
    property bool loadingActive: false

    // reloadOnVisible property ensures that the view has been always
    // loaded at least once while it is visible. When the view is loaded
    // while visible is set to false, there, what appears to be Chromium
    // optimizations that can disturb the loading.
    property bool reloadOnVisible: true

    // Profiles of WebViews are shared among all views of the same type (regular or
    // private). However, within each group of tabs, we can have some tabs that are
    // using mobile or desktop user agent. To avoid loading a page with the wrong
    // user agent, the agent is checked in the beginning of the loading at onLoadingChanged
    // handler. If the user agent is wrong, loading is stopped and reloadOnMatchingAgents
    // property is set to true. As soon as the agent is correct, the page is loaded.
    property bool reloadOnMatchingAgents: false

    // Used to follow whether agents match
    property bool agentsMatch: profile.httpUserAgent === userAgent.userAgent

    // URL that was requested and should be used
    // as a base for user interaction. It reflects
    // last request (successful or failed)
    property url requestedUrl: url

    property int findInPageResultIndex
    property int findInPageResultCount

    // Used to hide certain context menu items
    property bool isAppView: false

    // url to keep last url to return from reader mode
    property url readerSourceUrl

    // string to keep last title to return from reader mode
    property string readerTitle

    // Used for pdf generated to preview before print
    property url printPreviewUrl: ""
    property bool generatingPdf: false
    property int printedPageOrientation: WebEngineView.Portrait
    property int printedPageSizeId: WebEngineView.A4

    Shortcut {
        enabled: webEngineView.isFullScreen
        sequence: "Esc"
        onActivated: webEngineView.fullScreenCancelled();
    }

    settings {
        autoLoadImages: true
        javascriptEnabled: true
        // Disable builtin error pages in favor of our own
        errorPageEnabled: false
        // Load larger touch icons
        touchIconsEnabled: true
        // Disable scrollbars on mobile
        showScrollBars: true
        // Generally allow screen sharing, still needs permission from the user
        screenCaptureEnabled: true
        // Enables a web page to request that one of its HTML elements be made to occupy the user's entire screen
        fullScreenSupportEnabled: true
        // Turns on printing of CSS backgrounds when printing a web page
        printElementBackgrounds: false
    }

    focus: true
    onLoadingChanged: loadRequest => {
        print("    url: " + loadRequest.url + " " + loadRequest.status)

        /* Handle
        *  - WebEngineView::LoadStartedStatus,
        *  - WebEngineView::LoadStoppedStatus,
        *  - WebEngineView::LoadSucceededStatus and
        *  - WebEngineView::LoadFailedStatus
        */
        var ec = null;
        var es = "";
        var ed = null;
        if (loadRequest.status === WebEngineView.LoadStartedStatus) {
            if (profile.httpUserAgent !== userAgent.userAgent) {
                //print("Mismatch of user agents, will load later " + loadRequest.url);
                reloadOnMatchingAgents = true;
                stopLoading();
            } else {
                loadingActive = true;
            }
        }
        if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
            if (!privateMode) {
                const request = {
                    url: currentWebView.url,
                    title: currentWebView.title,
                    icon: currentWebView.icon
                }

                WebApp.BrowserManager.addToHistory(request);
                WebApp.BrowserManager.updateLastVisited(currentWebView.url);
            }

            ec = null;
            es = "";
            ed = null;
            loadingActive = false;
        }
        if (loadRequest.status === WebEngineView.LoadFailedStatus) {
            print("Load failed: " + loadRequest.errorCode + " " + loadRequest.errorString);
            print("Load failed url: " + loadRequest.url + " " + url);
            ec = loadRequest.errorCode;
            es = loadRequest.errorString;
            ed = loadRequest.errorDomain
            loadingActive = false;

            // update requested URL only after its clear that it fails.
            // Otherwise, its updated as a part of url property update.
            if (requestedUrl !== loadRequest.url)
                requestedUrl = loadRequest.url;
        }
        errorCode = ec;
        errorDomain = ed;
        errorString = es;
    }

    Component.onCompleted: {
        print("WebView completed.");
        print("Settings: " + webEngineView.settings);
    }

    onIconChanged: {
        if (icon && !privateMode) {
            WebApp.BrowserManager.updateIcon(url, icon)
        }
    }
    onNewWindowRequested: request => {
        // Just open in a browser for now
        Qt.openUrlExternally(request.requestedUrl.toString());

        // // If a new window is requested, just open it
        // if (request.userInitiated) {
        //     tabsModel.newTab(request.requestedUrl.toString())
        //     showPassiveNotification(i18nc("@info:status", "Website was opened in a new tab"))
        // } else {
        //     // TODO: should we allow user input?
        //     questionLoader.setSource("NewTabQuestion.qml")
        //     questionLoader.item.url = request.requestedUrl
        //     questionLoader.item.visible = true
        // }
    }
    onUrlChanged: {
        if (requestedUrl !== url) {
            requestedUrl = url;
        }
    }

    onFullScreenRequested: request => {
        if (request.toggleOn) {
            webBrowser.showFullScreen()
            const message = i18nc("@info:status", "Entered Full Screen mode")
            const actionText = i18nc("@action:button", "Exit Full Screen (Esc)")
            showPassiveNotification(message, "short", actionText, function() { webEngineView.fullScreenCancelled() });
        } else {
            webBrowser.showNormal()
        }

        request.accept()
    }

    onContextMenuRequested: request => {
        request.accepted = true // Make sure QtWebEngine doesn't show its own context menu.
        contextMenu.request = request
        contextMenu.x = request.position.x
        contextMenu.y = request.position.y
        contextMenu.open()
    }

    onAuthenticationDialogRequested: request => {
        request.accepted = true
        sheetLoader.setSource("AuthSheet.qml")
        sheetLoader.item.request = request
        sheetLoader.item.open()
    }

    onFeaturePermissionRequested: (securityOrigin, feature) => {
        let newQuestion = rootPage.questions.newPermissionQuestion()
        newQuestion.permission = feature
        newQuestion.origin = securityOrigin
        newQuestion.visible = true
    }

    onJavaScriptDialogRequested: request => {
        request.accepted = true;
        sheetLoader.setSource("JavaScriptDialogSheet.qml");
        sheetLoader.item.request = request;
        sheetLoader.item.open();
    }

    onFindTextFinished: result => {
        findInPageResultIndex = result.activeMatch;
        findInPageResultCount = result.numberOfMatches;
    }

    onVisibleChanged: {
        if (visible && reloadOnVisible) {
            // see description of reloadOnVisible above for reasoning
            reloadOnVisible = false;
            reload();
        }
    }

    onAgentsMatchChanged: {
        if (agentsMatch && reloadOnMatchingAgents) {
            // see description of reloadOnMatchingAgents above for reasoning
            reloadOnMatchingAgents = false;
            reload();
        }
    }

    onCertificateError: error => {
        error.defer();
        errorHandler.enqueue(error);
    }

    function findInPageForward(text) {
        findText(text);
    }

    function stopLoading() {
        loadingActive = false;
        stop();
    }

    onLinkHovered: hoveredUrl => hoveredLink.text = hoveredUrl

    QQC2.Label {
        id: hoveredLink
        visible: text.length > 0
        z: 2
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        leftPadding: Kirigami.Units.smallSpacing
        rightPadding: Kirigami.Units.smallSpacing
        color: Kirigami.Theme.textColor
        font.pointSize: Kirigami.Theme.defaultFont.pointSize - 1

        background: Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
        }
    }

    QQC2.Menu {
        id: contextMenu
        property ContextMenuRequest request
        property bool isValidUrl: contextMenu.request && contextMenu.request.linkUrl != "" // not strict equality
        property bool isAudio: contextMenu.request && contextMenu.request.mediaType === ContextMenuRequest.MediaTypeAudio
        property bool isImage: contextMenu.request && contextMenu.request.mediaType === ContextMenuRequest.MediaTypeImage
        property bool isVideo: contextMenu.request && contextMenu.request.mediaType === ContextMenuRequest.MediaTypeVideo
        property real playbackRate: 100

        onAboutToShow: {
            if (webEngineView.settings.javascriptEnabled && (contextMenu.isAudio || contextMenu.isVideo)) {
                const point = contextMenu.request.x + ', ' + contextMenu.request.y
                const js = 'document.elementFromPoint(' + point + ').playbackRate * 100;'
                webEngineView.runJavaScript(js, function(result) { contextMenu.playbackRate = result })
            }
        }

        QQC2.MenuItem {
            visible: contextMenu.isAudio || contextMenu.isVideo
            height: visible ? implicitHeight : 0
            text: contextMenu.request && contextMenu.request.mediaFlags & ContextMenuRequest.MediaPaused
            ? i18nc("@action:inmenu", "Play")
            : i18nc("@action:inmenu", "Pause")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.ToggleMediaPlayPause)
        }
        QQC2.MenuItem {
            visible: contextMenu.request && contextMenu.request.mediaFlags & ContextMenuRequest.MediaHasAudio
            height: visible ? implicitHeight : 0
            text:  contextMenu.request && contextMenu.request.mediaFlags & ContextMenuRequest.MediaMuted
            ? i18nc("@action:inmenu", "Unmute")
            : i18nc("@action:inmenu", "Mute")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.ToggleMediaMute)
        }
        QQC2.MenuItem {
            visible: webEngineView.settings.javascriptEnabled && (contextMenu.isAudio || contextMenu.isVideo)
            height: visible ? implicitHeight : 0
            contentItem: RowLayout {
                QQC2.Label {
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.fillWidth: true
                    text: i18nc("@label", "Speed")
                }
                QQC2.SpinBox {
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    value: contextMenu.playbackRate
                    from: 25
                    to: 1000
                    stepSize: 25
                    onValueModified: {
                        contextMenu.playbackRate = value
                        const point = contextMenu.request.x + ', ' + contextMenu.request.y
                        const js = 'document.elementFromPoint(' + point + ').playbackRate = ' + contextMenu.playbackRate / 100 + ';'
                        webEngineView.runJavaScript(js)
                    }
                    textFromValue: function(value, locale) {
                        return Number(value / 100).toLocaleString(locale, 'f', 2)
                    }
                }
            }
        }
        QQC2.MenuItem {
            visible: contextMenu.isAudio || contextMenu.isVideo
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Loop")
            checked: contextMenu.request && contextMenu.request.mediaFlags & ContextMenuRequest.MediaLoop
            onTriggered: webEngineView.triggerWebAction(WebEngineView.ToggleMediaLoop)
        }
        QQC2.MenuItem {
            visible: webEngineView.settings.javascriptEnabled && contextMenu.isVideo
            height: visible ? implicitHeight : 0
            text: webEngineView.isFullScreen ? i18nc("@action:inmenu", "Exit Fullscreen") : i18nc("@action:inmenu", "Enter Fullscreen")
            onTriggered: {
                const point = contextMenu.request.x + ', ' + contextMenu.request.y
                const js = webEngineView.isFullScreen
                    ? 'document.exitFullscreen()'
                    : 'document.elementFromPoint(' + point + ').requestFullscreen()'
                webEngineView.runJavaScript(js)
            }
        }
        QQC2.MenuItem {
            visible: webEngineView.settings.javascriptEnabled && (contextMenu.isAudio || contextMenu.isVideo)
            height: visible ? implicitHeight : 0
            text: contextMenu.request && contextMenu.request.mediaFlags & ContextMenuRequest.MediaControls
            ? i18nc("@action:inmenu", "Hide Controls")
            : i18nc("@action:inmenu", "Show Controls")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.ToggleMediaControls)
        }
        QQC2.MenuSeparator { visible: contextMenu.isAudio || contextMenu.isVideo }
        QQC2.MenuItem {
            visible: (contextMenu.isAudio || contextMenu.isVideo) && contextMenu.request.mediaUrl !== currentWebView.url
            height: visible ? implicitHeight : 0
            text: webEngineView.isAppView
                ? contextMenu.isVideo ? i18nc("@action:inmenu", "Open Video") : i18nc("@action:inmenu", "Open Audio")
                : contextMenu.isVideo ? i18nc("@action:inmenu", "Open Video in New Tab") : i18nc("@action:inmenu", "Open Audio in New Tab")
            onTriggered: {
                Qt.openUrlExternally(contextMenu.request.mediaUrl);
            }
        }
        QQC2.MenuItem {
            visible: contextMenu.isVideo
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Save Video")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.DownloadMediaToDisk)
        }
        QQC2.MenuItem {
            visible: contextMenu.isVideo
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Copy Video Link")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.CopyMediaUrlToClipboard)
        }
        QQC2.MenuItem {
            visible: contextMenu.isImage && contextMenu.request.mediaUrl !== currentWebView.url
            height: visible ? implicitHeight : 0
            text: webEngineView.isAppView ? i18nc("@action:inmenu", "Open Image") : i18nc("@action:inmenu", "Open Image in New Tab")
            onTriggered: {
                Qt.openUrlExternally(contextMenu.request.mediaUrl);
            }
        }
        QQC2.MenuItem {
            visible: contextMenu.isImage
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Save Image")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.DownloadImageToDisk)
        }
        QQC2.MenuItem {
            visible: contextMenu.isImage
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Copy Image")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.CopyImageToClipboard)
        }
        QQC2.MenuItem {
            visible: contextMenu.isImage
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Copy Image Link")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.CopyImageUrlToClipboard)
        }
        QQC2.MenuItem {
            visible: contextMenu.request && contextMenu.isValidUrl
            height: visible ? implicitHeight : 0
            text: webEngineView.isAppView ? i18nc("@action:inmenu", "Open Link") : i18nc("@action:inmenu", "Open Link in New Window")
            onTriggered: {
                Qt.openUrlExternally(contextMenu.request.linkUrl);
            }
        }
        QQC2.MenuItem {
            visible: contextMenu.request && contextMenu.isValidUrl
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Save Link")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.DownloadLinkToDisk)
        }
        QQC2.MenuItem {
            visible: contextMenu.request && contextMenu.isValidUrl
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Copy Link")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.CopyLinkToClipboard)
        }
        QQC2.MenuSeparator { visible: contextMenu.request && contextMenu.isValidUrl }
        QQC2.MenuItem {
            visible: contextMenu.request && (contextMenu.request.editFlags & ContextMenuRequest.CanCopy) && contextMenu.request.mediaUrl == ""
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Copy")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Copy)
        }
        QQC2.MenuItem {
            visible: contextMenu.request && (contextMenu.request.editFlags & ContextMenuRequest.CanCut)
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Cut")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Cut)
        }
        QQC2.MenuItem {
            visible: contextMenu.request && (contextMenu.request.editFlags & ContextMenuRequest.CanPaste)
            height: visible ? implicitHeight : 0
            text: i18nc("@action:inmenu", "Paste")
            onTriggered: webEngineView.triggerWebAction(WebEngineView.Paste)
        }
    }
}
