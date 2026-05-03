// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solar_transaction.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSolarTransactionCollection on Isar {
  IsarCollection<SolarTransaction> get solarTransactions => this.collection();
}

const SolarTransactionSchema = CollectionSchema(
  name: r'SolarTransaction',
  id: -6266446039116245210,
  properties: {
    r'amountPaid': PropertySchema(
      id: 0,
      name: r'amountPaid',
      type: IsarType.double,
    ),
    r'code': PropertySchema(
      id: 1,
      name: r'code',
      type: IsarType.string,
    ),
    r'contactCode': PropertySchema(
      id: 2,
      name: r'contactCode',
      type: IsarType.string,
    ),
    r'contactName': PropertySchema(
      id: 3,
      name: r'contactName',
      type: IsarType.string,
    ),
    r'contactPhone': PropertySchema(
      id: 4,
      name: r'contactPhone',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 5,
      name: r'kind',
      type: IsarType.byte,
      enumMap: _SolarTransactionkindEnumValueMap,
    ),
    r'panelName': PropertySchema(
      id: 6,
      name: r'panelName',
      type: IsarType.string,
    ),
    r'pricePerWatt': PropertySchema(
      id: 7,
      name: r'pricePerWatt',
      type: IsarType.double,
    ),
    r'productCode': PropertySchema(
      id: 8,
      name: r'productCode',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 9,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'remainingBalance': PropertySchema(
      id: 10,
      name: r'remainingBalance',
      type: IsarType.double,
    ),
    r'timestamp': PropertySchema(
      id: 11,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'totalAmount': PropertySchema(
      id: 12,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'totalWatts': PropertySchema(
      id: 13,
      name: r'totalWatts',
      type: IsarType.long,
    ),
    r'wattsPerPanel': PropertySchema(
      id: 14,
      name: r'wattsPerPanel',
      type: IsarType.long,
    )
  },
  estimateSize: _solarTransactionEstimateSize,
  serialize: _solarTransactionSerialize,
  deserialize: _solarTransactionDeserialize,
  deserializeProp: _solarTransactionDeserializeProp,
  idName: r'id',
  indexes: {
    r'code': IndexSchema(
      id: 329780482934683790,
      name: r'code',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'code',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'contact': LinkSchema(
      id: -3080700016958892023,
      name: r'contact',
      target: r'Contact',
      single: true,
    ),
    r'product': LinkSchema(
      id: 895536183151488217,
      name: r'product',
      target: r'Product',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _solarTransactionGetId,
  getLinks: _solarTransactionGetLinks,
  attach: _solarTransactionAttach,
  version: '3.1.0+1',
);

int _solarTransactionEstimateSize(
  SolarTransaction object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.code.length * 3;
  bytesCount += 3 + object.contactCode.length * 3;
  bytesCount += 3 + object.contactName.length * 3;
  {
    final value = object.contactPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.panelName.length * 3;
  bytesCount += 3 + object.productCode.length * 3;
  return bytesCount;
}

void _solarTransactionSerialize(
  SolarTransaction object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amountPaid);
  writer.writeString(offsets[1], object.code);
  writer.writeString(offsets[2], object.contactCode);
  writer.writeString(offsets[3], object.contactName);
  writer.writeString(offsets[4], object.contactPhone);
  writer.writeByte(offsets[5], object.kind.index);
  writer.writeString(offsets[6], object.panelName);
  writer.writeDouble(offsets[7], object.pricePerWatt);
  writer.writeString(offsets[8], object.productCode);
  writer.writeLong(offsets[9], object.quantity);
  writer.writeDouble(offsets[10], object.remainingBalance);
  writer.writeDateTime(offsets[11], object.timestamp);
  writer.writeDouble(offsets[12], object.totalAmount);
  writer.writeLong(offsets[13], object.totalWatts);
  writer.writeLong(offsets[14], object.wattsPerPanel);
}

SolarTransaction _solarTransactionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SolarTransaction();
  object.amountPaid = reader.readDouble(offsets[0]);
  object.code = reader.readString(offsets[1]);
  object.contactCode = reader.readString(offsets[2]);
  object.contactName = reader.readString(offsets[3]);
  object.contactPhone = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.kind =
      _SolarTransactionkindValueEnumMap[reader.readByteOrNull(offsets[5])] ??
          TransactionKind.purchase;
  object.panelName = reader.readString(offsets[6]);
  object.pricePerWatt = reader.readDouble(offsets[7]);
  object.productCode = reader.readString(offsets[8]);
  object.quantity = reader.readLong(offsets[9]);
  object.remainingBalance = reader.readDouble(offsets[10]);
  object.timestamp = reader.readDateTime(offsets[11]);
  object.totalAmount = reader.readDouble(offsets[12]);
  object.wattsPerPanel = reader.readLong(offsets[14]);
  return object;
}

P _solarTransactionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_SolarTransactionkindValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TransactionKind.purchase) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SolarTransactionkindEnumValueMap = {
  'purchase': 0,
  'sale': 1,
};
const _SolarTransactionkindValueEnumMap = {
  0: TransactionKind.purchase,
  1: TransactionKind.sale,
};

Id _solarTransactionGetId(SolarTransaction object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _solarTransactionGetLinks(SolarTransaction object) {
  return [object.contact, object.product];
}

void _solarTransactionAttach(
    IsarCollection<dynamic> col, Id id, SolarTransaction object) {
  object.id = id;
  object.contact.attach(col, col.isar.collection<Contact>(), r'contact', id);
  object.product.attach(col, col.isar.collection<Product>(), r'product', id);
}

extension SolarTransactionByIndex on IsarCollection<SolarTransaction> {
  Future<SolarTransaction?> getByCode(String code) {
    return getByIndex(r'code', [code]);
  }

  SolarTransaction? getByCodeSync(String code) {
    return getByIndexSync(r'code', [code]);
  }

  Future<bool> deleteByCode(String code) {
    return deleteByIndex(r'code', [code]);
  }

  bool deleteByCodeSync(String code) {
    return deleteByIndexSync(r'code', [code]);
  }

  Future<List<SolarTransaction?>> getAllByCode(List<String> codeValues) {
    final values = codeValues.map((e) => [e]).toList();
    return getAllByIndex(r'code', values);
  }

  List<SolarTransaction?> getAllByCodeSync(List<String> codeValues) {
    final values = codeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'code', values);
  }

  Future<int> deleteAllByCode(List<String> codeValues) {
    final values = codeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'code', values);
  }

  int deleteAllByCodeSync(List<String> codeValues) {
    final values = codeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'code', values);
  }

  Future<Id> putByCode(SolarTransaction object) {
    return putByIndex(r'code', object);
  }

  Id putByCodeSync(SolarTransaction object, {bool saveLinks = true}) {
    return putByIndexSync(r'code', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCode(List<SolarTransaction> objects) {
    return putAllByIndex(r'code', objects);
  }

  List<Id> putAllByCodeSync(List<SolarTransaction> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'code', objects, saveLinks: saveLinks);
  }
}

extension SolarTransactionQueryWhereSort
    on QueryBuilder<SolarTransaction, SolarTransaction, QWhere> {
  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SolarTransactionQueryWhere
    on QueryBuilder<SolarTransaction, SolarTransaction, QWhereClause> {
  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhereClause>
      codeEqualTo(String code) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'code',
        value: [code],
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterWhereClause>
      codeNotEqualTo(String code) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [],
              upper: [code],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [code],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [code],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'code',
              lower: [],
              upper: [code],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SolarTransactionQueryFilter
    on QueryBuilder<SolarTransaction, SolarTransaction, QFilterCondition> {
  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      amountPaidEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      amountPaidGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      amountPaidLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountPaid',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      amountPaidBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountPaid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'code',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'code',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'code',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      codeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'code',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactName',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactName',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contactPhone',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contactPhone',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contactPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contactPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      kindEqualTo(TransactionKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      kindGreaterThan(
    TransactionKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      kindLessThan(
    TransactionKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      kindBetween(
    TransactionKind lower,
    TransactionKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'panelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'panelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'panelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'panelName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'panelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'panelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'panelName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'panelName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'panelName',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      panelNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'panelName',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      pricePerWattEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pricePerWatt',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      pricePerWattGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pricePerWatt',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      pricePerWattLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pricePerWatt',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      pricePerWattBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pricePerWatt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      remainingBalanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remainingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      remainingBalanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remainingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      remainingBalanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remainingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      remainingBalanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remainingBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalWattsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalWatts',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalWattsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalWatts',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalWattsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalWatts',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      totalWattsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalWatts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      wattsPerPanelEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wattsPerPanel',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      wattsPerPanelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wattsPerPanel',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      wattsPerPanelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wattsPerPanel',
        value: value,
      ));
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      wattsPerPanelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wattsPerPanel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SolarTransactionQueryObject
    on QueryBuilder<SolarTransaction, SolarTransaction, QFilterCondition> {}

extension SolarTransactionQueryLinks
    on QueryBuilder<SolarTransaction, SolarTransaction, QFilterCondition> {
  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contact(FilterQuery<Contact> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'contact');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      contactIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'contact', 0, true, 0, true);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      product(FilterQuery<Product> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'product');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterFilterCondition>
      productIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'product', 0, true, 0, true);
    });
  }
}

extension SolarTransactionQuerySortBy
    on QueryBuilder<SolarTransaction, SolarTransaction, QSortBy> {
  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByAmountPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPaid', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByAmountPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPaid', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy> sortByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByContactCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactCode', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByContactCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactCode', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByPanelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'panelName', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByPanelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'panelName', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByPricePerWatt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerWatt', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByPricePerWattDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerWatt', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByProductCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByProductCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByRemainingBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingBalance', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByRemainingBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingBalance', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByTotalWatts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWatts', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByTotalWattsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWatts', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByWattsPerPanel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wattsPerPanel', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      sortByWattsPerPanelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wattsPerPanel', Sort.desc);
    });
  }
}

extension SolarTransactionQuerySortThenBy
    on QueryBuilder<SolarTransaction, SolarTransaction, QSortThenBy> {
  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByAmountPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPaid', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByAmountPaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountPaid', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy> thenByCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'code', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByContactCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactCode', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByContactCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactCode', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactName', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contactPhone', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByPanelName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'panelName', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByPanelNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'panelName', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByPricePerWatt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerWatt', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByPricePerWattDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pricePerWatt', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByProductCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByProductCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productCode', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByRemainingBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingBalance', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByRemainingBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingBalance', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByTotalWatts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWatts', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByTotalWattsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWatts', Sort.desc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByWattsPerPanel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wattsPerPanel', Sort.asc);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QAfterSortBy>
      thenByWattsPerPanelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wattsPerPanel', Sort.desc);
    });
  }
}

extension SolarTransactionQueryWhereDistinct
    on QueryBuilder<SolarTransaction, SolarTransaction, QDistinct> {
  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByAmountPaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountPaid');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct> distinctByCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'code', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByContactCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByContactName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByContactPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contactPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct> distinctByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByPanelName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'panelName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByPricePerWatt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pricePerWatt');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByProductCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByRemainingBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remainingBalance');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByTotalWatts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalWatts');
    });
  }

  QueryBuilder<SolarTransaction, SolarTransaction, QDistinct>
      distinctByWattsPerPanel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wattsPerPanel');
    });
  }
}

extension SolarTransactionQueryProperty
    on QueryBuilder<SolarTransaction, SolarTransaction, QQueryProperty> {
  QueryBuilder<SolarTransaction, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SolarTransaction, double, QQueryOperations>
      amountPaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountPaid');
    });
  }

  QueryBuilder<SolarTransaction, String, QQueryOperations> codeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'code');
    });
  }

  QueryBuilder<SolarTransaction, String, QQueryOperations>
      contactCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactCode');
    });
  }

  QueryBuilder<SolarTransaction, String, QQueryOperations>
      contactNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactName');
    });
  }

  QueryBuilder<SolarTransaction, String?, QQueryOperations>
      contactPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contactPhone');
    });
  }

  QueryBuilder<SolarTransaction, TransactionKind, QQueryOperations>
      kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<SolarTransaction, String, QQueryOperations> panelNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'panelName');
    });
  }

  QueryBuilder<SolarTransaction, double, QQueryOperations>
      pricePerWattProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pricePerWatt');
    });
  }

  QueryBuilder<SolarTransaction, String, QQueryOperations>
      productCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productCode');
    });
  }

  QueryBuilder<SolarTransaction, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<SolarTransaction, double, QQueryOperations>
      remainingBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remainingBalance');
    });
  }

  QueryBuilder<SolarTransaction, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<SolarTransaction, double, QQueryOperations>
      totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<SolarTransaction, int, QQueryOperations> totalWattsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalWatts');
    });
  }

  QueryBuilder<SolarTransaction, int, QQueryOperations>
      wattsPerPanelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wattsPerPanel');
    });
  }
}
