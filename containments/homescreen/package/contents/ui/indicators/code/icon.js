/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
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
 
