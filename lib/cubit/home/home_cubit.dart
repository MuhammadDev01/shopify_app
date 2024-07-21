import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_app/components/constants.dart';
import 'package:shop_app/helper/dio_helper.dart';
import 'package:shop_app/helper/end_points.dart';
import 'package:shop_app/models/categories_model.dart';
import 'package:shop_app/models/favourites_model.dart';
import 'package:shop_app/models/get_favourites_model.dart';
import 'package:shop_app/models/home_model.dart';
import 'package:shop_app/models/login_model.dart';
import 'package:shop_app/pages/category_page.dart';
import 'package:shop_app/pages/favourite_page.dart';
import 'package:shop_app/pages/product_page.dart';
import 'package:shop_app/pages/settings_page.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());
  static HomeCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List<Widget> pages = [
    const ProductPage(),
    const FavouritePage(),
    const CategoryPage(),
    const SettingsPage(),
  ];
  void changeNavBarIndex(int index) {
    currentIndex = index;
    emit(HomeChangeNavBarState());
  }

  HomeModel? homeModel;
  Map<int, bool> favorites = {};
  void getHomeData() {
    emit(HomeLoadingState());
    DioHelper.getData(
      url: hOME,
      token: token,
    ).then((value) {
      homeModel = HomeModel.fromJson(value.data);
      favorites.clear();
      for (var element in homeModel!.data.products) {
        favorites.addAll({
          element.id: element.inFavorites!,
        });
      }
      debugPrint(token);

      emit(HomeSuccessState());
    }).catchError((error) {
      debugPrint(error.toString());
      emit(HomeFailureState());
    });
  }

  CategoriesModel? categoriesModel;
  void getCategoriesData() {
    DioHelper.getData(
      url: cATEGORIES,
    ).then((value) {
      categoriesModel = CategoriesModel.fromJson(value.data);
      emit(CategoriesSuccessState());
    }).catchError((error) {
      debugPrint(error.toString());
      emit(CategoriesFailureState());
    });
  }

  FavouritesModel? favouritesModel;
  void postFavouritesData({required int productId}) {
    favorites[productId] = !favorites[productId]!;
    emit(FavouritesChangeState());
    DioHelper.postData(
      url: fAVOURITES,
      data: {
        'product_id': productId,
      },
      token: token,
    ).then(
      (value) {
        favouritesModel = FavouritesModel.fromJson(value.data);
        if (!favouritesModel!.status) {
          favorites[productId] = !favorites[productId]!;
        }
        getFavouritesData();
        emit(FavouritesSuccessState(
          favouritesModel: favouritesModel,
        ));
      },
    ).catchError(
      (error) {
        favorites[productId] = !favorites[productId]!;
        emit(FavouritesChangeState());
        debugPrint(error.toString());
        emit(FavouritesFailureState(
          error: favouritesModel!.message,
        ));
      },
    );
  }

  GetFavouritesModel? getFavouritesModel;
  void getFavouritesData() {
    emit(GetFavouritesLoadingState());
    DioHelper.getData(
      url: fAVOURITES,
      token: token,
    ).then((value) {
      getFavouritesModel = GetFavouritesModel.fromJson(value.data);
      emit(GetFavouritesSuccessState());
    }).catchError((error) {
      debugPrint(error.toString());
      emit(GetFavouritesFailureState());
    });
  }

  LoginModel? userModel;
  void getProfileData() {
    emit(GetProfileLoadingState());
    DioHelper.getData(
      url: pROFILE,
      token: token,
    ).then((value) {
      userModel = LoginModel.fromJson(value.data);
      emit(GetProfileSuccessState(userModel: userModel!));
    });
  }

  void updateUserProfile({
    required String email,
    String? password,
    required String name,
    required String phone,
  })  {
    emit(UpdateProfileLoadingState());
    DioHelper.putData(
      url: uPDATEPROFILE,
      token: token,
      data: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
    ).then((value) {
      userModel = LoginModel.fromJson(value.data);
      emit(UpdateProfileSuccessState(updateUserModel: userModel!));
    }).catchError((error) {
      debugPrint(error.toString());
      emit(UpdateProfileFailureState());
    });
  }
}
