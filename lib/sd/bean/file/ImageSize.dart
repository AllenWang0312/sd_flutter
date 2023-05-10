
class ImageSize{
  int width = 0;
  int height = 0;
  double aspectRatio = 0;

  ImageSize(this.width, this.height){
    aspectRatio = width*1.0/height;
  }
}