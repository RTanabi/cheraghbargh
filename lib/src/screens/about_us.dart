import 'package:cheraghbargh/src/components/marquee_text.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart';
import 'package:cheraghbargh/src/redux/actions.dart';
import 'package:cheraghbargh/src/redux/store.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: StoreConnector<AppState, AboutUsViewModel>(
        distinct: true,
        converter: AboutUsViewModel.fromStore,
        builder: (context, vm) {
          return Scaffold(
            appBar: AppBar(
              title: MarqueeWidget(
                child: Text(
                  "درباره ما",
                  style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
                ),
              ),
              centerTitle: true,
            ),
            body: Container(
              child: AboutUsWidget(vm: vm),
            ),
            floatingActionButton: TabSelector(),
          );
        },
      ),
    );
  }
}

class AboutUsWidget extends StatelessWidget {
  final AboutUsViewModel vm;
  const AboutUsWidget({Key key, this.vm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              vm.aboutUs != null && vm.aboutUs.isNotEmpty
                  ? vm.aboutUs
                  : """ همکار گرامی اپلیکیشن چراغ برق مسیری تازه در جهت اطلاع رسانی آنلاین قیمت قطعات یدکی خودرو بازرگانان استان تهیه گردیده است ، تا علاوه بر آنلاین بودن قیمت‌ها ، قابل مقایسه بین برند ها و بازرگانان برای تمام فروشندگان صنعت یدکی خودرو باشد.
با توجه به اینکه تا بدین روز نمونه‌ای از این اپلیکیشن ساخته نشده است و با توجه به گستره محصولات و برند ها در صورتی که پیشنهادی در جهت توسعه خدمات اپلیکیشن یا درخواست معرفی بازرگانی خود و یا مشکل فنی در معرفی قطعات مشاهده شد میتوانید پیغام خود را از طریق شماره تلگرام و یا واتساپ 09331512899 به پشتیبانی اپلیکیشن منتقل کنید ‌.
شایان ذکر است آنلاین بودن قیمت قطعات و تعیین نوع شرایط پرداخت برعهده بازرگانان بوده و مدیریت اپلیکیشن هیچگونه دخالتی در آن ندارد.
برای دریافت کد معرف می‌توانید به بازرگانان خود در استان مراجعه و کد معرف تهیه فرمایید.
با توجه به درج قیمت قطعات یدکی در اپلیکیشن از گسترش و انتقال آن به افراد غیر ضرور جدا خودداری نمایید، در صورت مشاهده اکانت کاربری شما از طرف مدیریت اپلیکیشن حذف خواهد شد. """,
              style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 19),
            ),
            SizedBox(height: 70)
          ],
        ),
      ),
    );
  }
}

class AboutUsViewModel {
  final String aboutUs;
  final Function(String) setAboutUsDispatch;

  AboutUsViewModel({
    @required this.aboutUs,
    @required this.setAboutUsDispatch,
  });

  static AboutUsViewModel fromStore(Store<AppState> store) {
    return AboutUsViewModel(
      aboutUs: store.state.aboutUs,
      setAboutUsDispatch: (String merchantsList) {
        store.dispatch(AboutUsAction(merchantsList));
      },
    );
  }
}
