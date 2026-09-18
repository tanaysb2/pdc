import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdc/Resuable%20components/app_bar.dart';
import 'package:pdc/Resuable%20components/text_field.dart';
import 'package:pdc/Screens/Competitor/add_competitor_barcode_screen.dart';
import 'package:pdc/Screens/Competitor/view_competitor_barcodes_screen.dart';

class CompetitorModuleScreen extends StatelessWidget {
  final String location;

  const CompetitorModuleScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            CustomAppBar(
              text: "Competitor",
              trailingIcon: ClipRRect(
                borderRadius: BorderRadius.circular(16.w),
                child: Image.asset(
                  "assets/jklogo.png",
                  height: 60.h,
                  width: 60.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                crossAxisCount: 3,
                crossAxisSpacing: 4.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 0.9,
                children: [
                  _CompetitorTile(
                    imagePath: "assets/scanbarcode.svg",
                    name: "Add Barcode",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AddCompetitorBarcodeScreen(location: location),
                        ),
                      );
                    },
                  ),
                  _CompetitorTile(
                    imagePath: "assets/report.svg",
                    name: "View Barcodes",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewCompetitorBarcodesScreen(location: location),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitorTile extends StatelessWidget {
  final String imagePath;
  final String name;
  final VoidCallback onTap;

  const _CompetitorTile({
    required this.imagePath,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 10.h),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 215, 237, 255),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              imagePath,
              fit: BoxFit.cover,
              height: 80.h,
              width: 80.w,
              // ignore: deprecated_member_use
              color: Colors.black,
            ),
            SizedBox(height: 20.h),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textFieldStyle(
                  color: const Color.fromARGB(255, 7, 70, 122),
                  fontSize: 28.sp,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
