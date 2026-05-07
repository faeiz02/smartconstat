import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ConstatDetail } from './constat-detail';

describe('ConstatDetail', () => {
  let component: ConstatDetail;
  let fixture: ComponentFixture<ConstatDetail>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ConstatDetail],
    }).compileComponents();

    fixture = TestBed.createComponent(ConstatDetail);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
