/*
    SPDX-FileCopyrightText: 2014-2015 Harald Sitter <sitter@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

function name(volume, muted, prefix) {
    if (!prefix) {
        prefix = "audio-volume";
    }
    var icon = null;
    var percent = volume / maxVolumeValue;
    if (percent <= 0.0 || muted) {
        icon = prefix + "-muted";
    } else if (percent <= 0.25) {
        icon = prefix + "-low";
    } else if (percent <= 0.75) {
        icon = prefix + "-medium";
    } else {
        icon = prefix + "-high";
    }
    return icon;
}

function formFactorIcon(formFactor) {
    switch(formFactor) {
        case "internal":
            return "audio-card";
        case "speaker":
            return "audio-speakers-symbolic";
        case "phone":
            return "phone";
        case "handset":
            return "phone";
        case "tv":
            return "video-television";
        case "webcam":
            return "camera-web";
        case "microphone":
            return "audio-input-microphone";
        case "headset":
            return "audio-headset";
        case "headphone":
            return "audio-headphones";
        case "hands-free":
            return "hands-free";
        case "car":
            return "car";
        case "hifi":
            return "hifi";
        case "computer":
            return "computer";
        case "portable":
            return "portable";
    }
    return "";
}
 
