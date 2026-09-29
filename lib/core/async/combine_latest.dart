import 'dart:async';

/// Combina dos streams emitiendo cada vez que cualquiera de ellos cambia.
///
/// La primera emisión ocurre cuando todos han emitido al menos una vez. Las
/// suscripciones se cancelan al cerrarse el stream resultante.
Stream<R> combineLatest2<A, B, R>(
  Stream<A> a$,
  Stream<B> b$,
  R Function(A, B) combine,
) => _combineLatest<R>([
  a$,
  b$,
], (values) => combine(values[0] as A, values[1] as B));

/// Variante de [combineLatest2] para tres streams.
Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> a$,
  Stream<B> b$,
  Stream<C> c$,
  R Function(A, B, C) combine,
) => _combineLatest<R>([
  a$,
  b$,
  c$,
], (values) => combine(values[0] as A, values[1] as B, values[2] as C));

/// Variante de [combineLatest2] para cuatro streams.
Stream<R> combineLatest4<A, B, C, D, R>(
  Stream<A> a$,
  Stream<B> b$,
  Stream<C> c$,
  Stream<D> d$,
  R Function(A, B, C, D) combine,
) => _combineLatest<R>(
  [a$, b$, c$, d$],
  (values) =>
      combine(values[0] as A, values[1] as B, values[2] as C, values[3] as D),
);

/// Variante de [combineLatest2] para cinco streams.
Stream<R> combineLatest5<A, B, C, D, E, R>(
  Stream<A> a$,
  Stream<B> b$,
  Stream<C> c$,
  Stream<D> d$,
  Stream<E> e$,
  R Function(A, B, C, D, E) combine,
) => _combineLatest<R>(
  [a$, b$, c$, d$, e$],
  (values) => combine(
    values[0] as A,
    values[1] as B,
    values[2] as C,
    values[3] as D,
    values[4] as E,
  ),
);

Stream<R> _combineLatest<R>(
  List<Stream<Object?>> sources,
  R Function(List<Object?>) combine,
) {
  late StreamController<R> controller;
  final values = List<Object?>.filled(sources.length, null);
  final ready = List<bool>.filled(sources.length, false);
  final subscriptions = <StreamSubscription<Object?>>[];

  void emitIfReady() {
    if (controller.isClosed) return;
    if (ready.every((value) => value)) controller.add(combine(values));
  }

  controller = StreamController<R>(
    onListen: () {
      for (var index = 0; index < sources.length; index++) {
        final sourceIndex = index;
        subscriptions.add(
          sources[sourceIndex].listen((value) {
            values[sourceIndex] = value;
            ready[sourceIndex] = true;
            emitIfReady();
          }),
        );
      }

      controller.onCancel = () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    },
  );

  return controller.stream;
}
