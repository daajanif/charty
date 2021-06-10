import 'package:mighty_notes/main.dart';
import 'package:mighty_notes/model/SubscriptionModel.dart';
import 'package:mighty_notes/services/BaseService.dart';
import 'package:mighty_notes/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

class SubscriptionService extends BaseService {
  SubscriptionService() {
    ref = db.collection('subscription');
  }

  Future<List<SubscriptionModel>> getSubscription() {
    return ref.where('userId', isEqualTo: getStringAsync(USER_ID)).get().then((value) {
      return value.docs.map((e) => SubscriptionModel.fromJson(e.data())).toList();
    });
  }

  Stream<List<SubscriptionModel>> subscription() {
    return ref.where('userId', isEqualTo: getStringAsync(USER_ID)).snapshots().map((event) => event.docs.map((e) => SubscriptionModel.fromJson(e.data())).toList());
  }
}
