import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mighty_notes/components/DashboardDrawerWidget.dart';
import 'package:mighty_notes/components/FilterNoteByColorDialogWidget.dart';
import 'package:mighty_notes/components/LockNoteDialogWidget.dart';
import 'package:mighty_notes/components/NoteLayoutDialogWidget.dart';
import 'package:mighty_notes/components/SetMasterPasswordDialogWidget.dart';
import 'package:mighty_notes/main.dart';
import 'package:mighty_notes/model/NotesModel.dart';
import 'package:mighty_notes/screens/AddNotesScreen.dart';
import 'package:mighty_notes/screens/AddToDoScreen.dart';
import 'package:mighty_notes/utils/Colors.dart';
import 'package:mighty_notes/utils/Common.dart';
import 'package:mighty_notes/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/Common.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  String colorFilter = '';

  String name;
  String userEmail;
  String imageUrl;

  DateTime currentBackPressTime;

  int crossAxisCount;
  int fitWithCount;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    fitWithCount = getIntAsync(FIT_COUNT, defaultValue: 1);
    crossAxisCount = getIntAsync(CROSS_COUNT, defaultValue: 2);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null || now.difference(currentBackPressTime) > 2.seconds) {
            currentBackPressTime = now;
            toast('Press back again to exit app');
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
          key: _scaffoldState,
          appBar: AppBar(
            title: Text(mAppName.validate()),
            actions: [
              IconButton(
                icon: Icon(Icons.color_lens_outlined),
                onPressed: () {
                  filterByColor();
                },
              ),
              IconButton(
                icon: getLayoutTypeIcon(),
                onPressed: () async {
                  noteLayoutDialog();
                },
              ),
            ],
            leading: IconButton(
              icon: Icon(Icons.menu_rounded),
              onPressed: () {
                _scaffoldState.currentState.openDrawer();
              },
            ),
          ),
          drawer: DashboardDrawerWidget(),
          body: StreamBuilder<List<NotesModel>>(
            stream: notesService.fetchNotes(color: colorFilter),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return noDataWidget(context).center();
                } else {
                  return Scrollbar(
                    child: StaggeredGridView.countBuilder(
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(fitWithCount),
                      mainAxisSpacing: 8,
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      addAutomaticKeepAlives: false,
                      padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        NotesModel notes = snapshot.data[index];

                        if (notes.checkListModel.validate().isNotEmpty) {
                          return GestureDetector(
                            onLongPress: () {
                              HapticFeedback.vibrate();
                              lockNoteOption(notesModel: notes);
                            },
                            child: Container(
                              decoration: boxDecorationWithShadow(
                                borderRadius: BorderRadius.circular(20),
                                backgroundColor: getColorFromHex(notes.color) ?? Colors.white,
                                spreadRadius: 1.0,
                                blurRadius: 1.0,
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  notes.isLock
                                      ? Container(child: Icon(Icons.lock, color: scaffoldColorDark)).paddingOnly(top: 16).center()
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: notes.checkListModel.take(5).length,
                                          itemBuilder: (_, index) {
                                            CheckListModel checkListData = notes.checkListModel[index];

                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  height: 12,
                                                  width: 12,
                                                  decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.black)),
                                                  child: checkListData.isCompleted ? Icon(Icons.check, size: 10, color: Colors.black) : SizedBox(),
                                                ).paddingAll(8),
                                                Text(
                                                  checkListData.todo.validate(),
                                                  style: primaryTextStyle(
                                                    decoration: checkListData.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                                    color: checkListData.isCompleted ? Colors.grey : Colors.black,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ).expand(),
                                              ],
                                            );
                                          },
                                        ).paddingTop(8),
                                  notes.checkListModel.length > 5 ? Text('more...', style: secondaryTextStyle()).paddingLeft(8) : SizedBox(),
                                  Align(
                                    child: Text(formatTime(notes.updatedAt.millisecondsSinceEpoch.validate()), style: secondaryTextStyle(size: 10, color: Colors.grey.shade900)),
                                    alignment: Alignment.bottomRight,
                                  ).paddingAll(16),
                                  notes.collaborateWith.first != getStringAsync(USER_EMAIL)
                                      ? Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300),
                                          child: Text(notes.collaborateWith.first[0], style: boldTextStyle(color: Colors.black, size: 12)),
                                        )
                                      : SizedBox()
                                ],
                              ),
                            ).onTap(() {
                              if (notes.isLock) {
                                showDialog(
                                  context: context,
                                  builder: (_) => LockNoteDialogWidget(onSubmit: (aIsRight) {
                                    finish(context);
                                    AddToDoScreen(notesModel: notes).launch(context);
                                  }),
                                );
                              } else {
                                AddToDoScreen(notesModel: notes).launch(context);
                              }
                            }),
                          );
                        } else {
                          return GestureDetector(
                            onLongPress: () {
                              HapticFeedback.vibrate();
                              lockNoteOption(notesModel: notes);
                            },
                            child: Container(
                              padding: EdgeInsets.all(17),

                              decoration: boxDecorationWithShadow(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                backgroundColor: getColorFromHex(notes.color) ?? Colors.white,
                                spreadRadius: 0.0,
                                offset: Offset(0.0, 0.0), //(x,y)
                                blurRadius: 0.0,
                                border: Border.all(color: Colors.blueGrey.shade400),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  notes.isLock
                                      ? Container(child: Icon(Icons.lock, color: scaffoldColorDark)).paddingOnly(top: 8, bottom: 8).center()
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(notes.noteTitle.validate(), style: boldTextStyle(color: Colors.black), maxLines: 1, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis),
                                            Text(notes.note, style: primaryTextStyle(size: 12, color: Colors.black), maxLines: 10, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                  Align(
                                    child: Text(formatTime(notes.updatedAt.millisecondsSinceEpoch.validate()), style: secondaryTextStyle(size: 10, color: Colors.grey.shade900)),
                                    alignment: Alignment.bottomRight,
                                  ),
                                  notes.collaborateWith.first != getStringAsync(USER_EMAIL)
                                      ? Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300),
                                          child: Text(notes.collaborateWith.first[0], style: boldTextStyle(color: Colors.black, size: 12)),
                                        )
                                      : SizedBox()
                                ],
                              ).onTap(() {
                                if (notes.isLock) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => LockNoteDialogWidget(onSubmit: (aIsRight) {
                                      finish(context);
                                      AddNotesScreen(notesModel: notes).launch(context);
                                    }),
                                  );
                                } else {
                                  AddNotesScreen(notesModel: notes).launch(context);
                                }
                              }),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }
              }
              return snapWidgetHelper(snapshot, loadingWidget: Loader(color: appStore.isDarkMode ? scaffoldColorDark : PrimaryColor));
            },
          ),
          floatingActionButton: Observer(
            builder: (_) => FloatingActionButton(
              backgroundColor: appStore.isDarkMode ? PrimaryColor : scaffoldColorDark,
              child: Icon(Icons.add, color: appStore.isDarkMode ? scaffoldColorDark : Colors.white),
              onPressed: () {
                selectNoteType();
              },
            ),
          ),
        ),
      ),
    );
  }

  lockNoteOption({NotesModel notesModel}) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Text('Select Option', style: secondaryTextStyle(size: 18)).center().paddingAll(8),
              Divider(height: 16),
              ListTile(
                leading: Icon(notesModel.isLock ? Icons.lock_open_rounded : Icons.lock_outline_rounded, color: appStore.isDarkMode ? PrimaryColor : scaffoldSecondaryDark),
                title: Text(notesModel.isLock ? 'Unlock Note' : 'Lock Note', style: primaryTextStyle()),
                onTap: () {
                  finish(context);
                  if (getStringAsync(USER_MASTER_PWD).isNotEmpty) {
                    if (notesModel.collaborateWith.first == getStringAsync(USER_EMAIL)) {
                      lockNoteDialog(notesModel);
                    } else {
                      toast('This is shared note, changes not allow');
                    }
                  } else {
                    setLockNoteDialog(notesModel);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_rounded, color: appStore.isDarkMode ? PrimaryColor : scaffoldSecondaryDark),
                title: Text('Delete Note', style: primaryTextStyle()),
                onTap: () async {
                  finish(context);
                  if (notesModel.collaborateWith.first == getStringAsync(USER_EMAIL)) {
                    bool delete = await showInDialog(
                      context,
                      title: Text('Delete note', style: primaryTextStyle()),
                      child: Text('Confirm to delete note?', style: primaryTextStyle()),
                      actions: [
                        TextButton(
                            onPressed: () {
                              finish(context, false);
                            },
                            child: Text('cancel', style: primaryTextStyle())),
                        TextButton(
                            onPressed: () {
                              finish(context, true);
                            },
                            child: Text('delete', style: primaryTextStyle())),
                      ],
                    );
                    if (delete) {
                      notesService.removeDocument(notesModel.noteId).then((value) {
                        toast('note deleted');
                      }).catchError((error) {
                        toast(error.toString());
                      });
                    }
                  } else {
                    toast('This is shared note, changes not allow');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  selectNoteType() {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Text('New', style: secondaryTextStyle(size: 18)).center().paddingAll(8),
              Divider(height: 16),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: appStore.isDarkMode ? PrimaryColor : scaffoldSecondaryDark),
                title: Text('Add Note', style: primaryTextStyle()),
                onTap: () {
                  finish(context);
                  AddNotesScreen().launch(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.check_box_outlined, color: appStore.isDarkMode ? PrimaryColor : scaffoldSecondaryDark),
                title: Text('Add ToDo', style: primaryTextStyle()),
                onTap: () {
                  finish(context);
                  AddToDoScreen().launch(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  noteLayoutDialog() {
    return showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      titleTextStyle: primaryTextStyle(size: 20),
      title: Text('Select layout').paddingBottom(16),
      child: NoteLayoutDialogWidget(onLayoutSelect: (fitCount, crossCount) async {
        await setValue(FIT_COUNT, fitCount);
        await setValue(CROSS_COUNT, crossCount);
        setState(() {
          fitWithCount = fitCount;
          crossAxisCount = crossCount;
        });
      }),
    );
  }

  setLockNoteDialog(NotesModel notesModel) {
    return showDialog(
      context: context,
      builder: (_) {
        return SetMasterPasswordDialogWidget(userId: getStringAsync(USER_ID), notesModel: notesModel);
      },
    );
  }

  lockNoteDialog(NotesModel notesModel) {
    return showDialog(
      context: context,
      builder: (_) {
        return LockNoteDialogWidget(
          onSubmit: (aIsRightPWD) {
            if (aIsRightPWD) {
              if (notesModel.isLock == true) {
                notesModel.isLock = false;
              } else {
                notesModel.isLock = true;
              }

              notesService.updateDocument({'isLock': notesModel.isLock}, notesModel.noteId).then((value) {
                finish(context);
              }).catchError((error) {
                toast(error.toString());
              });
            }
          },
        );
      },
    );
  }

  filterByColor() {
    return showInDialog(
      context,
      title: Text('Filter by color'),
      titleTextStyle: primaryTextStyle(size: 22),
      contentPadding: EdgeInsets.all(16),
      child: FilterNoteByColorDialogWidget(onColorTap: (color) {
        setState(() {
          colorFilter = color;
        });
      }),
    );
  }
}
