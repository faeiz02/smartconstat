import { TestBed } from '@angular/core/testing';

import { Constat } from './constat';

describe('Constat', () => {
  let service: Constat;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Constat);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
