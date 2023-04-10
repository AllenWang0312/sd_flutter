

main(){
  // String prompt = "a,<lora:aaa:0.8>,b,c";
  // print(prompt.replaceAll(RegExp(r"<lora:aaa:+([0-1]\.\d)>+"), ""));

  String prompt = "<lora:0 A chilloutmixgd_v10:1.0>, <lora:0 A chilloutmixgd_v10:1.0>,";
  print(prompt.contains("<lora:0 A chilloutmixgd_v10").toString());
}