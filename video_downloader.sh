#!/bin/bash
if [ "$1" = "--help" ]; then
echo "Please read the README.md on GitHub: https://github.com/zoardgodor/bash-video-downloader"
echo "--help     Show this help message."
echo "--download  Usage: ./video_downloader.sh --download <URL> Checks the available formats, the user selects one video format and one audio format and downloads the video."
exit
fi
if ! command -v ffmpeg &> /dev/null; then
echo "Please install ffmpeg. Do you want to install with apt? (y/n)"
read -r install_ffmpeg
if [ "$install_ffmpeg" == "y" ]; then
sudo apt update && sudo apt install ffmpeg -y
else
echo "Install ffmpeg with your package manager"
exit
fi
fi
cd "$(dirname "$0")"
case "$(uname -m)" in
x86_64) BIN="yt-dlp_linux";;
aarch64) BIN="yt-dlp_linux_aarch64";;
*) echo "Unsupported architecture: $(uname -m)"; exit;;
esac
if [ ! -f "./yt-dlp" ]; then
echo "Download $BIN from https://github.com/yt-dlp/yt-dlp/releases"
echo "Rename it to yt-dlp and put it next to this script."
exit
fi
chmod +x ./yt-dlp
echo "Everything is ready. Use --help for more information."
case "$1" in --download)
if [ -z "$2" ]; then
echo "Please provide a URL to download."
exit
fi
url="$2"
echo "Checking available formats for $url..."
formatSS=$(./yt-dlp -F "$url" 2>/dev/null)
printf '%s\n' "$formatSS" | awk 'NR>2 && $1 ~ /^[0-9]+$/ {
if ($3 == "audio")
printf "%-6s %-10s %-16s -\n", $1, $2, "audio only"
else
printf "%-6s %-10s %-16s %s\n", $1, $2, $3, $4
}'
echo "Please enter the format code for the video you want to download: (leave empty for no video or enter 'bestvideo' for the best quality)"
read -r format
if [ -n "$format" ]; then
echo "Do you want to download the audio as well? (y/n)"
read -r audioyn
if [ "$audioyn" = "y" ]; then
aformat=bestaudio
else
aformat=""
fi
else
echo "Please enter the format code for the audio you want to download: (leave empty for no audio or enter 'bestaudio' for the best quality)"
read -r aformat
fi
if [ -z "$format" ] && [ -z "$aformat" ]; then
echo "No format selected. Exiting."
exit
fi
# echo "Please enter the output filename (without extension) (leave empty for default):"
# read-r outname
# if [ -z "$outname" ]; then
# echo "No otput filename provided. Exiting.
# exit
outname=$(./yt-dlp --get-filename -f "bestvideo" "$url" 2>/dev/null)
echo "Please enter the output directory (leave empty for current directory):"
read -r outdir
if [ -z "$outdir" ]; then
outdir="."
fi
outname="$outdir/$outname.%(ext)s"
if  [ -z "$format" ]; then
echo "Downloading audio in format $aformat..."
./yt-dlp -f "$aformat" "$url" -o "$outname"
elif [ -z "$aformat" ]; then
echo "Downloading video in format $format..."
./yt-dlp -f "$format" "$url" -o "$outname"
else
echo "Downloading video in format $format and audio in format $aformat..."
./yt-dlp -f "$format+$aformat" "$url" -o "$outname"
fi
;;
*)
echo "Invalid option. Use --help";;
esac