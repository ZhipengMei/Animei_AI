echo '*****Begin to process image.*****'
echo "Image path: $1"
python s2p/s2p.py "$1"
echo '*****Image processing is finished.*****'
